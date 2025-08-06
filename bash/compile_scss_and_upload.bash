#!/bin/bash
# compile_scss_and_upload.bash

# Script pour compiler localement, uploader le CSS, ET vider le cache distant.

# Arrête le script si une commande échoue
set -e

# --- Configuration Serveur Distant (Centralisée ici) ---
REMOTE_USER="u584466092"
REMOTE_HOST="153.92.217.175"
SSH_PORT="65002"
# Chemin ABSOLU vers la RACINE de votre site Drupal sur le serveur
# C'est ici que se trouve le dossier 'vendor'
REMOTE_DRUPAL_ROOT="~/domains/chezfilms.fr/public_html" 
# --- Fin Configuration ---


# Détermine le dossier où se trouve ce script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

COMPILE_SCRIPT="${SCRIPT_DIR}/compile_scss.bash"
UPLOAD_SCRIPT="${SCRIPT_DIR}/upload.bash"

echo "▶️  Début du déploiement complet (Compilation + Upload + Cache Clear)..."
echo ""

# --- Étape 1: Compilation locale ---
if [ -f "$COMPILE_SCRIPT" ]; then
  echo "--- (1/3) Exécution de la compilation locale..."
  bash "$COMPILE_SCRIPT"
  echo "--- Compilation terminée."
else
  echo "❌ Erreur: Script de compilation introuvable: $COMPILE_SCRIPT"
  exit 1
fi

echo ""

# --- Étape 2: Upload du thème ---
if [ -f "$UPLOAD_SCRIPT" ]; then
  echo "--- (2/3) Exécution de l'upload du thème..."
  bash "$UPLOAD_SCRIPT"
  echo "--- Upload terminé."
else
  echo "❌ Erreur: Script d'upload introuvable: $UPLOAD_SCRIPT"
  exit 1
fi

echo ""

# --- Étape 3: Vider le cache Drupal sur le serveur distant ---
echo "--- (3/3) Exécution de 'drush cr' sur le serveur distant..."
ssh -p "${SSH_PORT}" "${REMOTE_USER}@${REMOTE_HOST}" "source ~/.bashrc && cd ${REMOTE_DRUPAL_ROOT} && ~/domains/chezfilms.fr/vendor/bin/drush cr -y"
echo "--- Cache distant vidé avec succès."
echo ""
echo "✅ Processus de déploiement terminé."

exit 0
