# Linguistique Régionale — application Flutter

Application mobile Flutter dédiée à la découverte, la recherche et la contribution autour des mots et expressions des régions et dialectes de Madagascar.

Le projet comprend une application Android/iOS et une API Spring Boot connectée à Supabase.

## Fonctionnalités

- Onboarding, inscription et connexion avec JWT.
- Consultation des régions, mots et expressions.
- Recherche par terme, région et type.
- Détails des mots et variantes régionales.
- Gestion des favoris synchronisés avec le compte utilisateur.
- Contribution de nouveaux mots et expressions.
- Interface multilingue français/malgache.

## Architecture

| Partie | Technologie | Dépôt |
|---|---|---|
| Application mobile | Flutter / Dart | `Linguistique_Regionnale_frontend` |
| API | Spring Boot / Java 21 | `Linguistique_Regionnale_backend` |
| Base de données | PostgreSQL / Supabase | Projet Supabase |

## Prérequis

- Flutter 3.22 ou version supérieure.
- Dart 3.4 ou version supérieure.
- Java 21 pour le backend.
- Un téléphone Android avec le débogage USB activé pour les tests physiques.

## Lancer l'application Flutter

Depuis le dossier frontend :

```bash
flutter pub get
flutter run -d 079354024K002703 \
  --dart-define=API_BASE_URL=https://linguistique-regionnale-backend.onrender.com/api
```

Remplacez `079354024K002703` par l'identifiant retourné par :

```bash
flutter devices
```

## Générer l'APK Android

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://linguistique-regionnale-backend.onrender.com/api
```

L'APK est généré dans :

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Backend distant

L'API de production est disponible à l'adresse :

```text
https://linguistique-regionnale-backend.onrender.com
```

Exemples de routes :

```text
GET  /api/regions
GET  /api/words
POST /api/auth/register
POST /api/auth/login
```

Le backend est déployé sur Render avec Docker. Les variables suivantes sont configurées sur la plateforme et ne doivent pas être ajoutées au dépôt GitHub :

```text
SUPABASE_DB_URL
SUPABASE_DB_USER
SUPABASE_DB_PASSWORD
JWT_SECRET
CORS_ORIGIN
```

## Développement local du backend

```bash
cd Linguistique_Regionnale_backend
export SUPABASE_DB_URL="jdbc:postgresql://..."
export SUPABASE_DB_USER="postgres.votre_project_ref"
export SUPABASE_DB_PASSWORD="votre_mot_de_passe"
export JWT_SECRET="une-cle-secrete-de-plus-de-32-caracteres"
SERVER_PORT=8082 ./mvnw spring-boot:run
```

## Dépôts GitHub

- Frontend : `https://github.com/amede-dev/Linguistique_Regionnale_frontend`
- Backend : `https://github.com/amede-dev/Linguistique_Regionnale_backend`

## Sécurité

Ne publiez jamais les mots de passe Supabase, le fichier `.env` ou la valeur réelle de `JWT_SECRET`. Utilisez les variables d'environnement de Render pour la production.
