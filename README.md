# Teny Gasy – application Flutter

Encyclopédie sonore des 18 dialectes de Madagascar. Projet Flutter converti à partir du prototype HTML `teny_gasy_app.html` (11 écrans, design system « Terre & Nature »).

## Démarrer

```bash
flutter create . --platforms=android,ios   # génère les dossiers android/ et ios/ (une seule fois)
flutter pub get
flutter run
flutter test
```
Prérequis : Flutter ≥ 3.22 (Dart ≥ 3.4).

## Structure

| Dossier | Contenu |
|---|---|
| `lib/core/` | `theme.dart` (palette, typo Plus Jakarta Sans), `app_state.dart` (favoris, auth, lecteur audio simulé), `nav.dart` |
| `lib/data/` | `models.dart`, `mock_data.dart` (mots, régions, variantes) |
| `lib/widgets/` | composants partagés : `AudioBar`, `WordCard`, `ChipsRow`, `PBtn`, `CtaCard`, champs et onglets d'auth |
| `lib/screens/` | Onboarding, Connexion, Inscription, Mot de passe oublié, `MainShell` (5 onglets : Accueil, Recherche, Régions, Favoris, Profil), Détail du mot, Contribuer |

## Ce qui fonctionne

- Parcours complet : Bienvenue → Inscription/Connexion (validation des formulaires) → application à 5 onglets → déconnexion.
- Recherche avec filtres région / type, tri (pertinence, Nord→Sud, popularité) et recherche texte.
- Favoris synchronisés entre tous les écrans (cœur/signet), retrait, filtres.
- Fiche mot avec variantes régionales filtrables, copie du terme, analyse étymologique.
- Contribution : formulaire et studio vocal de démonstration locale, avec validation des champs.
- Lecteur audio à forme d'onde, progression et vitesse (1.0x / 1.5x / 0.75x) – **simulé**.

## À brancher ensuite

- **Backend** : le prototype mentionne Supabase Auth. Remplacer les données de `mock_data.dart` et l'état de `app_state.dart` par des appels Supabase (`supabase_flutter`).
- **Audio réel** : intégrer `just_audio` (lecture) et `record` (micro) à la place des minuteurs simulés (`AppState.togglePlay`, `_toggleRecord`).
- **Partage / export** : `share_plus` et `pdf` pour « Partager » et « Exporter (.pdf) ».

## Backend local

Le dossier `backend/` contient l'API Spring Boot et le schéma SQL Supabase.

```bash
cd backend
export SUPABASE_DB_URL="jdbc:postgresql://..."
export SUPABASE_DB_USER="postgres"
export SUPABASE_DB_PASSWORD="..."
export JWT_SECRET="une-cle-secrete-d-au-moins-32-caracteres"
mvn spring-boot:run
```

Pour Android : `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api`
