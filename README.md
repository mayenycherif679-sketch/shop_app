# Shop App — Flutter production-ready

[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter)
![i18n](https://img.shields.io/badge/i18n-FR%20%7C%20EN-blue)
![Tests](https://img.shields.io/badge/tests-unit%20%7C%20widget%20%7C%20integration-brightgreen)

> Remplace `OWNER/REPO` par ton compte et ton dépôt GitHub dans les badges.

Application e-commerce connectée à une API REST réelle : authentification JWT avec refresh token, cache hors-ligne, favoris, FR/EN, accessibilité, tests complets et CI/CD.

## Captures d'écran
| Connexion | Produits | Détail | Favoris | Profil | Réglages |
|---|---|---|---|---|---|
| ![](docs/screenshots/login.png) | ![](docs/screenshots/products.png) | ![](docs/screenshots/detail.png) | ![](docs/screenshots/favorites.png) | ![](docs/screenshots/profile.png) | ![](docs/screenshots/settings.png) |

*(Ajouter les captures dans `docs/screenshots/`, idéalement une en mode hors-ligne et une en français.)*

## Fonctionnalités
- **7 écrans** : Connexion/Inscription, Produits, Catégories, Favoris, Profil, Détail produit, Réglages
- Auth JWT : inscription, connexion, déconnexion (avec confirmation), restauration de session, refresh automatique
- Cache Hive + **mode hors-ligne** (bandeau, données conservées, session restaurée hors-ligne)
- Favoris persistés sur l'appareil (non effacés à la déconnexion)
- **FR + EN** (langue du système par défaut, choix manuel dans Réglages)
- Accessibilité, images optimisées, rebuilds ciblés

## API
[Platzi Fake Store API](https://fakeapi.platzi.com) — `https://api.escuelajs.co/api/v1` (publique, sans clé).
`POST /users/`, `POST /auth/login`, `POST /auth/refresh-token`, `GET /auth/profile`, `GET /products`, `GET /categories`.

## Architecture (feature-first + couches Clean)
```
lib/
├── main.dart            # composition root : crée les vraies implémentations
├── app.dart             # ShopApp : providers + MaterialApp (dépendances injectées)
├── home_page.dart       # navigation (4 onglets)
├── l10n/                # AppLocalizations + strings FR/EN
├── core/
│   ├── network/         # buildDio, AuthInterceptor (Bearer + refresh)
│   ├── storage/         # CacheStore, PreferencesStore (Hive), TokenStorage (secure)
│   ├── utils/           # Failure/FailureType, cachedFetch
│   └── widgets/         # AsyncController/AsyncView, AppImage
└── features/
    ├── auth/      { domain, data, presentation }
    ├── catalog/   { domain, data, presentation }
    ├── favorites/ { domain, data, presentation }
    └── settings/
```
```
Page ─watch/select→ Controller (ChangeNotifier) ─→ Repository (interface, domain)
                                                         ▲
                                              RepositoryImpl (data)
                                               │                 │
                                       RemoteDataSource(Dio)   CacheStore / PreferencesStore (Hive)
```
- **domain** : entités + interfaces de repository, Dart pur.
- **data** : data sources (Dio), modèles JSON, implémentations. `cachedFetch` = réseau d'abord, cache en cas d'**erreur réseau uniquement**.
- **presentation** : pages + `ChangeNotifier` (Provider).
- **Testabilité** : `ShopApp` reçoit repositories et controllers ; les tests injectent des fakes (`test/fakes.dart`).

### Auth & erreurs
- `AuthInterceptor` : Bearer sur chaque requête ; sur 401, refresh puis rejeu ; refresh refusé => `sessionExpired()` => retour au login (même si une page est empilée).
- `Failure(type)` : réseau, identifiants invalides, 401, 403, 404, validation, 5xx. Le texte vient de `AppLocalizations.failureMessage` (donc traduit).

## Qualité
### Tests (`flutter test` + `flutter test integration_test`)
| Niveau | Fichiers | Ce qui est vérifié |
|---|---|---|
| Unitaires | `catalog_repository_test`, `auth_repository_test`, `failure_test`, `favorites_test`, `settings_controller_test`, `auth_controller_test`, `async_controller_test`, `l10n_strings_test` | Repositories (cache, hors-ligne, 403/500), controllers, persistance, parité FR/EN |
| Widgets | `test/widgets/*` | Validation du formulaire, erreur + Retry, bandeau hors-ligne, favoris, navigation vers le détail, images (ResizeImage), langues, **guidelines d'accessibilité** |
| Intégration | `integration_test/app_test.dart` | Login -> produit -> favori -> onglet Favoris ; logout ; changement de langue ; login refusé |

### Accessibilité
Tooltips sur les `IconButton`, `Semantics(header)` sur les titres, erreurs en `liveRegion`, images décoratives exclues et images de contenu étiquetées, champs avec `autofillHints`. Vérifié par `androidTapTargetGuideline` et `labeledTapTargetGuideline`.

### Performance
- `ListView.builder` / `GridView.builder` / `PageView.builder` : tout est construit et chargé à la demande (**lazy**).
- `AppImage` décode à la taille affichée (`cacheWidth`), fondu léger, `gaplessPlayback`.
- `itemExtent` fixe (mise en page O(1)), widgets `const`, `context.select` : un favori ne reconstruit que sa ligne.
- `IndexedStack` : les onglets ne se rechargent pas à chaque changement.

**Mesurer le 60 fps** (non automatisable en CI) : `flutter run --profile` sur un appareil réel, puis DevTools > Performance (aucune frame rouge en scrollant Produits/Catégories).

### Analyse statique
`flutter analyze` doit être propre (`flutter_lints` + `prefer_const_constructors`) ; c'est un job bloquant de la CI.

## CI/CD (`.github/workflows/ci.yml`)
1. **quality** : `flutter analyze` -> `flutter test --coverage` -> `flutter test integration_test`.
2. **build-apk** : APK release (`--split-per-abi`), artefact téléchargeable ; sur un tag `v*`, joint à la GitHub Release.

Publier une version : `git tag v1.2.0 && git push origin v1.2.0`.

## Installation
```bash
git clone https://github.com/OWNER/REPO.git && cd REPO
flutter create . --platforms=android,ios   # génère android/ ios/ (lib/ inchangé)
rm -f test/widget_test.dart
flutter pub get
flutter run
```
- Android : `minSdkVersion 23` requis par `flutter_secure_storage` (`android/app/build.gradle`).
- Compte de démonstration : `john@mail.com` / `changeme` (ou créer un compte).
- Lancer les tests : `flutter test` puis `flutter test integration_test`.
- APK local : `flutter build apk --release`.
- Signature de production : créer un keystore et `android/key.properties` (ignorés par git).

## Licence
MIT.
