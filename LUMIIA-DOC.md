# LUMIIA · Vendredi 13 · Documentation Technique

> Dernière mise à jour : mars 2026  
> Versions courantes : **client v2.0** / **admin v2.0**

---

## 1. Vue d'ensemble

Application web pour animer la soirée "Vendredi 13 — Destin ou Mérite ?" au bar LUMIIA.

**Deux fichiers HTML autonomes** (pas de serveur, pas de build) :
- `v13-client.html` → téléphones des invités
- `v13-admin.html` → grand écran animateur (16/9)

**Firebase Realtime Database** assure la synchronisation en temps réel.

---

## 2. Infrastructure

| Composant | Service | URL / Référence |
|-----------|---------|-----------------|
| Hébergement | GitHub Pages | `https://i-immersion.github.io/Vendredi13/` |
| Base de données | Firebase Realtime DB | `lumiia-live-default-rtdb.europe-west1` |
| Projet Firebase | lumiia-live | Console : console.firebase.google.com |
| Repo GitHub | I-immersion/Vendredi13 | `github.com/I-immersion/Vendredi13` |

### Config Firebase (dans les deux fichiers)
```javascript
apiKey:            "AIzaSyBPgjVFkzP88qX_hlFUFqL168XONfNIBA4"
authDomain:        "lumiia-live.firebaseapp.com"
databaseURL:       "https://lumiia-live-default-rtdb.europe-west1.firebasedatabase.app"
projectId:         "lumiia-live"
storageBucket:     "lumiia-live.appspot.com"
messagingSenderId: "823919513931"
appId:             "1:823919513931:web:6f6f3c7c6d1699457b18ce"
```

### Règles Firebase (valides jusqu'au 5 avril 2026)
```json
{
  "rules": {
    ".read":  "now < 1775340000000",
    ".write": "now < 1775340000000"
  }
}
```
> ⚠️ Penser à mettre à jour ces dates avant chaque soirée

---

## 3. Schéma Firebase (structure des données)

```
v13/
├── joueurs/
│   └── {joueurKey}/
│       ├── prenom         (string)
│       ├── equipe         (string : intuitif | stratege | chanceux | temeraire)
│       ├── role           (string : eclaireur | funambule | oracle | fantome | trickster)
│       ├── scores         (object : scores quiz par équipe)
│       ├── pointsPerso    (number : points accumulés en tant que performer)
│       ├── joinedAt       (timestamp Firebase)
│       └── voteEnvoye     (boolean)
│
├── votes/
│   └── {voteKey}/
│       ├── joueurKey      (string : clé du votant)
│       ├── prenom         (string : prénom du votant)
│       ├── equipe         (string : équipe du votant)
│       ├── noteEtoiles    (number : 1-5, points pour l'équipe)
│       ├── smileys        (object : {perso: 0-4, origi: 0-4}, points perso performer)
│       ├── pointsEquipe   (number : = noteEtoiles)
│       ├── pointsPerso    (number : = smileys.perso + smileys.origi)
│       └── ts             (timestamp Firebase)
│
└── etat/
    ├── type               (string : 'performer' | 'mission' | 'vote')
    ├── actif              (boolean)
    ├── joueurKey          (string : clé du performer actuel)
    ├── performerNom       (string)
    ├── equipe             (string)
    ├── role               (string)
    ├── missionTitre       (string, si type=mission)
    ├── missionDesc        (string, si type=mission)
    ├── duree              (number, si type=mission)
    └── ts                 (timestamp Firebase)
```

---

## 4. Boucle de jeu (gameplay)

```
1. TIRAGE  → Admin clique "Tirer au sort"
             → Slot machine défile les noms
             → Un joueur est sélectionné (anti-répétition : évite les 5 derniers)
             → Firebase reçoit : etat.type = 'performer'
             → Client du performer : page "C'est toi !"
             → Autres clients : page d'attente

2. MISSION → Admin fait tourner la roue (ou clique une mission manuellement)
             → Admin clique "Lancer la mission"
             → Firebase reçoit : etat.type = 'mission', actif = true
             → Client performer : page mission + chrono 20s
             → Chrono 20s sur grand écran ET téléphone performer

3. VOTE    → Admin clique "Ouvrir le vote"
             → Firebase reçoit : etat.type = 'vote', actif = true
             → Tous les clients : page vote
             → Vote : ⭐ /5 (points équipe) + 😄 personnalité + 🤩 originalité (points perso)
             → Résultats temps réel sur l'admin
             → Admin ferme le vote

4. RETOUR  → Tour suivant → recommencer en 1
```

---

## 5. Système de points

| Critère | Qui vote | Points pour qui |
|---------|----------|-----------------|
| ⭐ Note /5 | Tout le public | L'**équipe** du performer |
| 😄 Personnalité (smiley 0-4) | Tout le public | Le **performer** personnellement |
| 🤩 Originalité (smiley 0-4) | Tout le public | Le **performer** personnellement |

---

## 6. Anti-répétition performers

Variable `derniersPerformers` (tableau de 5 clés max) dans l'admin.  
Un joueur dans ce tableau ne peut pas être tiré à nouveau tant que 5 autres ne sont pas passés.  
Se réinitialise automatiquement si tous les joueurs sont dans le tableau.

---

## 7. Comment modifier le contenu

### Changer les missions
Dans `v13-admin.html`, chercher le commentaire `CONFIG MISSIONS` :
```javascript
const MISSIONS = [
  { titre:"Nom de la mission", desc:"Description complète", roles:["all"], duree:20 },
  // Ajouter/modifier ici
];
```
- `roles: ["all"]` = tout le monde peut tomber dessus
- `roles: ["oracle","eclaireur"]` = seulement ces rôles
- `duree` = secondes (20 par défaut)

### Changer les équipes
Chercher `CONFIG ÉQUIPES` dans les deux fichiers.  
**Important** : modifier dans les DEUX fichiers (client + admin).

### Changer les rôles
Chercher `CONFIG RÔLES` dans les deux fichiers.  
**Important** : modifier dans les DEUX fichiers.

### Changer les questions du quiz
Dans `v13-client.html` uniquement, chercher `CONFIG QUIZ`.

### Changer la durée par défaut des missions
Modifier `duree:20` dans chaque mission du tableau MISSIONS.

---

## 8. Déploiement

### Procédure standard
```bash
# Depuis : /Users/emmanuelexbrayat/Dropbox/DB LUMIIA 2025/LUMIIA Experiences/Les jeux/Vendredi 13/
git add -A
git commit -m "description de la modif"
git push origin main
```
GitHub Pages se met à jour automatiquement en ~2 minutes.

### URLs de production
- Client : `https://i-immersion.github.io/Vendredi13/v13-client.html`
- Admin  : `https://i-immersion.github.io/Vendredi13/v13-admin.html`

### Convention de nommage fichiers
- `v13-client.html` → fichier actif en production (URL fixe, QR codes pointent ici)
- `v13-admin.html`  → fichier actif en production
- `v13-client-v2.0.html` → archive versionnée dans Dropbox

---

## 9. Avant chaque soirée

- [ ] Vérifier les règles Firebase (dates valides)
- [ ] Ouvrir l'admin sur Chrome, faire un test avec un téléphone
- [ ] Cliquer "Reset" pour effacer les données de la soirée précédente
- [ ] QR code client affiché à l'entrée

---

## 10. Risques techniques & limites

| Risque | Probabilité | Solution |
|--------|-------------|----------|
| Règles Firebase expirées | Moyen | Mettre à jour les dates dans la console Firebase avant chaque événement |
| Dépassement plan gratuit Firebase | Faible (100 connexions max) | Pour les grandes soirées, envisager plan Blaze |
| Données accumulées | Certain à long terme | Bouton "Reset" dans l'admin à utiliser entre chaque soirée |
| GitHub Pages down | Très faible | Service très stable |
| SDK Firebase obsolète | Faible à moyen terme | Version 10.12.0 fixée dans les imports |

---

## 11. Structure interne des fichiers

Chaque fichier est organisé en sections commentées :
```
CONFIG FIREBASE     → clés de connexion
CONFIG ÉQUIPES      → noms, emojis, couleurs
CONFIG RÔLES        → liste des rôles
CONFIG MISSIONS     → (admin) liste des missions
CONFIG QUIZ         → (client) questions et scores
CONFIG VOTE         → smileys disponibles
AUDIO               → sons Web Audio
STATE               → variables d'état
UTILS               → fonctions utilitaires
[fonctions métier]  → logique de jeu
FIREBASE listeners  → écoute temps réel
INIT                → initialisation
```

---

## 12. Historique des versions

| Version | Date | Changements |
|---------|------|-------------|
| **v2.14 / v2.14** | 13/03/2026 | bug |
| **v2.13 / v2.13** | 13/03/2026 | bug |
| **v2.12 / v2.12** | 13/03/2026 | bug |
| **v2.11 / v2.11** | 13/03/2026 | bug |
| **v2.10 / v2.10** | 13/03/2026 | interface cliebnt |
| **v2.9 / v2.9** | 13/03/2026 | bugh |
| **v2.9 / v2.9** | 13/03/2026 | fix reset session locale + listener reset global au demarrage |
| **v2.9 / v2.9** | 13/03/2026 | bug |
| **v2.9 / v2.9** | 13/03/2026 | bug |
| **v2.9 / v2.9** | 13/03/2026 | bug |
| **v2.9 / v2.9** | 13/03/2026 | bug |
| **v2.9 / v2.9** | 13/03/2026 | - |
| **v2.8 / v2.8** | 13/03/2026 | - |
| **v2.8 / v2.8** | 13/03/2026 | - |
| **v2.8 / v2.8** | 13/03/2026 | - |
| **v2.7 / v2.7** | 13/03/2026 | nouvel onglet admin |
| **v2.6 / v2.6** | 13/03/2026 | - |
| **v2.6 / v2.6** | 13/03/2026 | MAJ des missions et interfaces |
| **v2.5 / v2.5** | 13/03/2026 | - |
| **v2.4 / v2.4** | 13/03/2026 | - |
| **v2.4 / v2.4** | 13/03/2026 | MAJ Interface clienbt |
| **v2.3 / v2.3** | 13/03/2026 | sync v2.3 + logo |
| **v2.3 / v2.3** | 13/03/2026 | maj |
| **v2.3 / v2.2** | 13/03/2026 | maj questions quiz |
| **v2.2 / v2.2** | 13/03/2026 | maj |
| **v2.2 / v2.2** | 13/03/2026 | ajout logo |
| **v2.2 / v2.2** | 13/03/2026 | Reset des clients |
| **v2.0 / v2.0** | 13/03/2026 | première version |
| v1.0 | Mars 2026 | Version initiale |
| v1.1 admin | Mars 2026 | Fix bug roueAngle |
| v1.2 admin | Mars 2026 | Fix bug COULEURS_ROUE |
| v1.1 client | Mars 2026 | Session localStorage |
| **v2.0** | Mars 2026 | Refonte complète : tirage slot machine, vote ⭐+smileys, layout 16/9 admin, liste joueurs avec surbrillance performer, sons Web Audio, documentation |
