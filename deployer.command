#!/bin/bash
# ════════════════════════════════════════════════
# LUMIIA · Vendredi 13 · Script de déploiement
# Double-cliquer pour déployer sur GitHub Pages
# ════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Chemin fixe vers le dossier ──
SCRIPT_DIR="/Users/emmanuelexbrayat/Dropbox/DB LUMIIA 2025/LUMIIA Experiences/Les jeux/Vendredi 13"
cd "$SCRIPT_DIR" || { echo -e "${RED}❌ Dossier introuvable : $SCRIPT_DIR${NC}"; read -p "Entrée pour fermer..."; exit 1; }

echo ""
echo -e "${BOLD}════════════════════════════════════${NC}"
echo -e "${BOLD}  LUMIIA · Déploiement Vendredi 13  ${NC}"
echo -e "${BOLD}════════════════════════════════════${NC}"
echo ""

# ── Vérifier les fichiers ──
if [ ! -f "v13-client.html" ] || [ ! -f "v13-admin.html" ]; then
  echo -e "${RED}❌ Fichiers v13-client.html ou v13-admin.html introuvables${NC}"
  read -p "Entrée pour fermer..."; exit 1
fi

# ── Lire les versions ──
CLIENT_VERSION=$(grep -o 'CLIENT v[0-9]*\.[0-9]*' v13-client.html | head -1 | sed 's/CLIENT //')
ADMIN_VERSION=$(grep -o 'ADMIN v[0-9]*\.[0-9]*' v13-admin.html | head -1 | sed 's/ADMIN //')
if [ -z "$CLIENT_VERSION" ]; then CLIENT_VERSION="?.?"; fi
if [ -z "$ADMIN_VERSION" ]; then ADMIN_VERSION="?.?"; fi

echo -e "📄 Client : ${CYAN}${CLIENT_VERSION}${NC}"
echo -e "📄 Admin  : ${CYAN}${ADMIN_VERSION}${NC}"
echo ""

# ── Message de commit ──
echo -e "${YELLOW}Message de déploiement (ex: ajout mission, fix chrono...)${NC}"
echo -n "> "
read -r COMMIT_MSG
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG="déploiement client ${CLIENT_VERSION} / admin ${ADMIN_VERSION}"
fi
echo ""

# ── Mettre à jour la doc ──
echo -e "📝 Mise à jour de la documentation..."
DATE_AUJOURDHUI=$(date "+%d/%m/%Y")
NOUVELLE_LIGNE="| **${CLIENT_VERSION} / ${ADMIN_VERSION}** | ${DATE_AUJOURDHUI} | ${COMMIT_MSG} |"

if [ -f "LUMIIA-DOC.md" ]; then
  python3 -c "
content = open('LUMIIA-DOC.md').read()
marker = '|---------|------|-------------|'
new_line = '${NOUVELLE_LIGNE}'
if marker in content:
    content = content.replace(marker, marker + '\n' + new_line, 1)
else:
    content += '\n\n## Historique des versions\n\n| Version | Date | Changements |\n|---------|------|-------------|\n' + new_line + '\n'
open('LUMIIA-DOC.md','w').write(content)
"
  echo -e "${GREEN}✓ Documentation mise à jour${NC}"
else
  echo -e "${YELLOW}⚠️  LUMIIA-DOC.md absent — ignoré${NC}"
fi

# ── Git push ──
echo ""
echo -e "🚀 Envoi sur GitHub..."
git add -A
git commit -m "[${CLIENT_VERSION}/${ADMIN_VERSION}] ${COMMIT_MSG}"
PUSH_RESULT=$(git push origin main 2>&1)
PUSH_CODE=$?

if [ $PUSH_CODE -eq 0 ]; then
  echo ""
  echo -e "${GREEN}${BOLD}✅ Déploiement réussi !${NC}"
  echo ""
  echo -e "   Client : ${CYAN}https://i-immersion.github.io/Vendredi13/v13-client.html${NC}"
  echo -e "   Admin  : ${CYAN}https://i-immersion.github.io/Vendredi13/v13-admin.html${NC}"
  echo ""
  echo -e "   GitHub Pages se met à jour dans ~2 minutes."
else
  echo ""
  echo -e "${RED}❌ Erreur push :${NC}"
  echo "$PUSH_RESULT"
fi

echo ""
echo -e "${BOLD}════════════════════════════════════${NC}"
echo ""
read -p "Appuie sur Entrée pour fermer..."
