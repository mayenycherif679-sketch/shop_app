# Shop App — Flutter connectée (Clean Architecture, JWT, cache hors-ligne)

![CI](../../actions/workflows/ci.yml/badge.svg)

Application Flutter full-stack : authentification JWT avec refresh token, 3 écrans alimentés par une API REST réelle, cache local Hive et mode hors-ligne.

## Fonctionnalités
| Exigence | Implémentation |
|---|---|
| Inscription / connexion / **déconnexion** | `LoginPage` (bascule login ⇄ register) ; bouton **déconnexion** dans l'AppBar (avec confirmation) et dans l'onglet Profil |
| 3 écrans de données API | **Produits** (`/products`), **Catégories** (`/categories`), **Profil** (`/auth/profile`, protégé) |
| Cache local | Hive (`HiveCacheStore`) |
| Mode hors-ligne | bandeau « Mode hors-ligne » + données du cache + bouton *Actualiser* |
| Erreurs réseau | messages typés, icône adaptée, bouton *Réessayer*, pull-to-refresh |
| Tests | 15 tests unitaires (repositories + mapping d'erreurs) |
| CI | GitHub Actions : analyse, tests, build APK |

## API utilisée
[Platzi Fake Store API](https://fakeapi.platzi.com) — `https://api.escuelajs.co/api/v1` (publique, sans clé).

| Usage | Endpoint |
|---|---|
| Inscription | `POST /users/` |
| Connexion | `POST /auth/login` → `access_token` + `refresh_token` |
| Refresh | `POST /auth/refresh-token` |
| Profil (protégé) | `GET /auth/profile` |
| Produits / Catégories | `GET /products`, `GET /categories` |

Compte de test pré-rempli : `john@mail.com` / `changeme`, ou crée ton compte.

## Architecture (Feature-First + couches Clean)

```
lib/
├── core/                       # code transversal
│   ├── network/                # buildDio + AuthInterceptor (token + refresh)
│   ├── storage/                # CacheStore (Hive), TokenStorage (secure storage)
│   ├── utils/                  # Failure/FailureType, cachedFetch, Cached<T>
│   └── widgets/                # AsyncController / AsyncView
├── features/
│   ├── auth/      { domain, data, presentation }
│   └── catalog/   { domain, data, presentation }
├── home_page.dart
└── main.dart                   # composition root
```

### Flux des données (dépendances vers l'intérieur)
```
Page (presentation) ─watch→ Controller (ChangeNotifier)
                                 │ appelle
                                 ▼
                       Repository (interface, domain)
                                 ▲ implémenté par
                       RepositoryImpl (data)
                          │               │
                 RemoteDataSource (Dio)   CacheStore (Hive)
```
- **domain** : entités + interfaces de repository, Dart pur, aucune dépendance Flutter/Dio/Hive.
- **data** : `RemoteDataSource` (appels Dio), modèles JSON qui étendent les entités, `RepositoryImpl` qui orchestre réseau + cache.
- **presentation** : pages Flutter + contrôleurs `ChangeNotifier`.

### Gestion d'état (Provider)
- `AuthController` (global) : `AuthStatus` (unknown / authenticated / unauthenticated). `App` écoute ce statut et affiche `LoginPage` ou `HomePage` : login, logout et expiration de session fonctionnent par simple changement d'état, sans navigation manuelle.
- `AsyncController<T>` (un par écran) : `data`, `loading`, `error`, `errorType`, `fromCache`. `AsyncView<T>` en déduit loader, erreur + *Réessayer*, bandeau hors-ligne ou contenu.
- Les repositories sont injectés via `Provider` ; l'instance `Dio` est créée **une seule fois** dans `main.dart` puis partagée.

### Mode hors-ligne (`cachedFetch`)
1. Appel API → succès : le JSON est écrit dans Hive.
2. **Erreur réseau** (pas de connexion, timeout) et cache présent → données du cache, `fromCache = true` → bandeau affiché.
3. Erreur réseau sans cache → message + *Réessayer*.
4. Erreur serveur / 401 / 403 / 404 → **jamais masquée** par le cache.

Au démarrage hors-ligne, la session est aussi restaurée grâce au profil en cache.

### Gestion des erreurs
`Failure.from()` convertit les exceptions Dio en `Failure(message, type)`.

| Type | Cas | Réaction UI |
|---|---|---|
| `network` | pas de connexion, timeouts | icône wifi coupé, cache si disponible |
| `unauthorized` | 401 / identifiants faux | message ; refresh automatique si possible |
| `forbidden` | 403 | message d'accès refusé (pas de refresh) |
| `notFound` | 404 | « Ressource introuvable » |
| `validation` | 400 / 422 | « données incorrectes ou email déjà utilisé » |
| `server` | 5xx | « serveur indisponible » |

### Intercepteur d'authentification
`AuthInterceptor` (`QueuedInterceptor`) :
1. ajoute `Authorization: Bearer <token>` ;
2. sur `401` → `POST /auth/refresh-token`, sauvegarde des tokens, rejeu de la requête ;
3. refresh refusé → tokens effacés, `AuthController.sessionExpired()` → retour au login ;
4. refresh impossible faute de réseau → tokens conservés.

Un client Dio interne (même `BaseOptions`) sans intercepteur est utilisé pour le refresh et le rejeu : c'est nécessaire pour éviter un deadlock dans un `QueuedInterceptor`. Les tokens sont dans `flutter_secure_storage` (Keychain / Keystore), jamais dans Hive. Logout = tokens + cache effacés.

## Installation
```bash
git clone <ton-repo> && cd shop_app
flutter create .          # génère android/ ios/ (ne modifie pas lib/)
rm -f test/widget_test.dart
flutter pub get
flutter run
```
- Android : `flutter_secure_storage` demande `minSdkVersion 23` (`android/app/build.gradle`).
- Release Android : vérifie la permission `INTERNET` dans `AndroidManifest.xml`.
- Aucune clé API : pour changer d'API, modifier `lib/core/config.dart`.

## Tests
```bash
flutter test
```
- `catalog_repository_test.dart` (7) : succès + cache, fallback cache (erreur réseau / timeout), hors-ligne sans cache, 500 et 403 non masqués.
- `auth_repository_test.dart` (5) : login, login 401, logout (tokens + cache), restauration hors-ligne, restauration sans token.
- `failure_test.dart` (1) : mapping HTTP → `FailureType`.

## Tester le mode hors-ligne
1. Lance l'app connecté, ouvre Produits et Catégories.
2. Active le mode avion et relance l'app.
3. Les données s'affichent avec le bandeau « Mode hors-ligne ».

## Pistes d'évolution
Pagination, `connectivity_plus` pour détecter le réseau en temps réel, injection avec `get_it`, migration vers Riverpod/Bloc.
