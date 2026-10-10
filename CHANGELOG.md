# Changelog

Format basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.1.0/) ;
versionnage [SemVer](https://semver.org/lang/fr/).

## [Unreleased]
### Prévu
- Pagination des produits, détection de connectivité en temps réel.

## [1.2.0] - 2026-10-20
Passage en production : tests complets, i18n, accessibilité, performance.

### Ajouté
- Écrans : **détail produit** (galerie paresseuse), **favoris** (persistés sur l'appareil), **réglages** (langue).
- **Internationalisation FR / EN** (langue du système par défaut, choix manuel persisté, prix formatés par `intl`).
- **Accessibilité** : tooltips / labels sémantiques sur tous les contrôles, titres `header`, messages d'erreur en `liveRegion`, cibles tactiles >= 48 dp.
- `AppImage` : images décodées à la taille d'affichage (`cacheWidth`), chargées paresseusement, fondu + fallback.
- Suite de tests : tests unitaires, tests de widgets, **tests d'intégration** (`integration_test/`).
- CI : build **APK release** (artefact + pièce jointe de release sur tag `v*`) et couverture.
- `CHANGELOG.md`.

### Modifié
- `ShopApp` reçoit toutes ses dépendances (injection) => app entièrement testable.
- Les erreurs sont typées (`FailureType`) et traduites côté UI : plus de texte utilisateur dans la couche données.
- Listes en `ListView.builder` + `itemExtent`, `context.select` pour limiter les rebuilds.
- Déconnexion factorisée (`confirmAndLogout`) : accessible depuis la barre d'application et le profil.
- Retour automatique à la racine de navigation quand la session expire.

### Supprimé
- Identifiants de démonstration pré-remplis dans le formulaire de connexion.

## [1.1.0] - 2026-10-08
Qualité et robustesse.

### Ajouté
- Écran **Profil** (`/auth/profile`) : 3 écrans de données API.
- Bouton de **déconnexion** avec confirmation ; effacement des tokens et du cache.
- Erreurs typées (réseau, 401, 403, 404, validation, 5xx) avec icône adaptée.
- CI GitHub Actions (analyse + tests), tests des repositories d'auth et du catalogue.

### Modifié
- `AuthInterceptor` : client de refresh avec les mêmes `BaseOptions` que le client principal ; 403 non traité comme une expiration de session.
- README enrichi (architecture, flux de données, gestion d'état).

## [1.0.0] - 2026-09-24
Première version.

### Ajouté
- Authentification **JWT** (inscription, connexion, déconnexion) sur la Platzi Fake Store API.
- Écrans Produits et Catégories alimentés par l'API REST (Dio).
- Cache local **Hive** et **mode hors-ligne** avec bandeau d'information.
- `AuthInterceptor` : injection du token et **refresh token** automatique sur 401.
- Architecture feature-first (domain / data / presentation) et Repository pattern.
