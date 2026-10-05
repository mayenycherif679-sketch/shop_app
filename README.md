# Shop App — Flutter connectée (Clean Architecture + cache hors-ligne)

Application Flutter full-stack : authentification JWT avec refresh token, 3 écrans alimentés par une API REST réelle, cache local Hive et mode hors-ligne.

## Fonctionnalités
- **Auth** : inscription, connexion, déconnexion, restauration de session au démarrage
- **3 écrans API** : Produits, Catégories, Profil (endpoint protégé)
- **Cache local** (Hive) + **mode hors-ligne** avec bandeau « données enregistrées »
- **Gestion d'erreurs** : messages utilisateur clairs (réseau, 401, 400, 5xx) + bouton *Réessayer* + pull-to-refresh

## API utilisée
[Platzi Fake Store API](https://fakeapi.platzi.com) — `https://api.escuelajs.co/api/v1` (publique, sans clé).

| Usage | Endpoint |
|---|---|
| Inscription | `POST /users/` |
| Connexion | `POST /auth/login` → `access_token` + `refresh_token` |
| Refresh | `POST /auth/refresh-token` |
| Profil (protégé) | `GET /auth/profile` |
| Produits / Catégories | `GET /products`, `GET /categories` |

Compte de test pré-rempli : `john@mail.com` / `changeme` (ou crée ton compte).

## Architecture (Feature-First + couches Clean)

```
lib/
├── core/                       # transversal
│   ├── network/                # Dio + AuthInterceptor (token + refresh)
│   ├── storage/                # CacheStore (Hive), TokenStorage (secure storage)
│   ├── utils/                  # Failure (erreurs UI), cachedFetch (stratégie cache)
│   └── widgets/                # AsyncController / AsyncView (loader, erreur, offline)
├── features/
│   ├── auth/      { domain, data, presentation }
│   └── catalog/   { domain, data, presentation }
├── home_page.dart
└── main.dart                   # composition root (injection manuelle)
```

- **domain** : entités + interfaces de repository (Dart pur, aucune dépendance)
- **data** : `RemoteDataSource` (Dio) + `RepositoryImpl` + modèles JSON
- **presentation** : pages + `ChangeNotifier` (Provider)

### Repository pattern & cache
`cachedFetch` implémente *network-first* : appel API → écriture du cache ; en cas d'**erreur réseau uniquement**, lecture du cache (`fromCache = true`). Une erreur serveur (500) n'est pas masquée par le cache.

### Intercepteur d'authentification
`AuthInterceptor` (Dio `QueuedInterceptor`) :
1. ajoute `Authorization: Bearer <token>` ;
2. sur `401` → `POST /auth/refresh-token`, sauvegarde des nouveaux tokens, rejeu de la requête ;
3. si le refresh échoue → tokens effacés, retour à l'écran de login.

Tokens stockés dans `flutter_secure_storage`, jamais dans le cache Hive. Le cache est vidé à la déconnexion.

## Installation
```bash
git clone <ton-repo> && cd shop_app
flutter create .          # génère android/ ios/ (ne touche pas à lib/)
flutter pub get
flutter run
```
> Après `flutter create .`, supprime `test/widget_test.dart` s'il a été généré.
> Android : `flutter_secure_storage` requiert `minSdkVersion 23` (android/app/build.gradle).
> Release Android : vérifie `<uses-permission android:name="android.permission.INTERNET"/>` dans `AndroidManifest.xml`.

Aucune clé à configurer. Pour changer d'API : `lib/core/config.dart`.

## Tests
```bash
flutter test
```
4 tests unitaires sur `CatalogRepositoryImpl` (mocktail) : succès + mise en cache, fallback cache hors-ligne, hors-ligne sans cache, erreur 500 non masquée.

## Tester le mode hors-ligne
1. Lance l'app connecté, ouvre Produits et Catégories.
2. Coupe le Wi-Fi / active le mode avion, relance l'app.
3. Les données s'affichent avec le bandeau « Mode hors-ligne ».
