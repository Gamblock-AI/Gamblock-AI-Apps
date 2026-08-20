#!/usr/bin/env bash
# ==============================================================================
# Setup and Upload Android Research Signing Keystore to GitHub Actions
# ==============================================================================
# This script generates/locates the persistent Android Research Keystore,
# validates it with keytool, and uploads the required secrets and variables to
# GitHub Actions environments ('pilot-signing' and 'release-signing') using gh CLI.
# ==============================================================================
set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BOLD}${BLUE}=== Gamblock-AI Android Research Signing Setup ===${NC}"
echo

# 1. Check prerequisites
for cmd in keytool gh base64; do
  if ! command -v "$cmd" &> /dev/null; then
    echo -e "${RED}[ERROR] Perintah '$cmd' tidak ditemukan. Pastikan sudah terinstal.${NC}"
    exit 1
  fi
done

# 2. Check GitHub CLI Authentication
if ! gh auth status &> /dev/null; then
  echo -e "${RED}[ERROR] GitHub CLI belum login. Silakan jalankan 'gh auth login' terlebih dahulu.${NC}"
  exit 1
fi

APP_REPO="${APP_REPO:-Gamblock-AI/Gamblock-AI-Apps}"
KEY_DIR="$HOME/.config/gamblock-ai/release-keys"
KEY_PATH="$KEY_DIR/gamblock-research.jks"
KEY_ALIAS="gamblock-research"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"
umask 077

echo -e "Repositori target: ${BOLD}${APP_REPO}${NC}"
echo -e "Lokasi keystore:  ${BOLD}${KEY_PATH}${NC}"
echo -e "Key alias:        ${BOLD}${KEY_ALIAS}${NC}"
echo

# 3. Create or use existing keystore
if [ -f "$KEY_PATH" ]; then
  echo -e "${YELLOW}[INFO] Ditemukan file keystore yang sudah ada di $KEY_PATH.${NC}"
  read -rsp "Masukkan password untuk keystore ini: " RESEARCH_PASSWORD
  echo
else
  echo -e "${BLUE}[INFO] Membuat keystore baru...${NC}"
  while true; do
    read -rsp "Masukkan password baru untuk Research Keystore (min. 6 karakter): " RESEARCH_PASSWORD
    echo
    if [ ${#RESEARCH_PASSWORD} -lt 6 ]; then
      echo -e "${RED}[ERROR] Password minimal 6 karakter. Silakan coba lagi.${NC}"
      continue
    fi
    read -rsp "Konfirmasi password: " CONFIRM_PASSWORD
    echo
    if [ "$RESEARCH_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
      echo -e "${RED}[ERROR] Password tidak cocok. Silakan coba lagi.${NC}"
      continue
    fi
    break
  done

  keytool -genkeypair -v \
    -keystore "$KEY_PATH" -storetype JKS \
    -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 \
    -sigalg SHA256withRSA -validity 10000 \
    -dname "CN=Gamblock-AI Research, O=Gamblock-AI, C=ID" \
    -storepass "$RESEARCH_PASSWORD" \
    -keypass "$RESEARCH_PASSWORD"
  echo -e "${GREEN}[OK] Keystore berhasil dibuat di $KEY_PATH.${NC}"
fi

# 4. Validate keystore with keytool
echo -e "${BLUE}[INFO] Memvalidasi keystore dengan keytool...${NC}"
if ! keytool -list -keystore "$KEY_PATH" -storepass "$RESEARCH_PASSWORD" -alias "$KEY_ALIAS" &> /dev/null; then
  echo -e "${RED}[ERROR] Password atau alias '$KEY_ALIAS' tidak valid untuk keystore ini.${NC}"
  exit 1
fi
echo -e "${GREEN}[OK] Keystore valid!${NC}"
echo

# 5. Upload variables and secrets to GitHub Actions
ENVIRONMENTS=("pilot-signing" "release-signing")

for ENV in "${ENVIRONMENTS[@]}"; do
  echo -e "${BLUE}[INFO] Mengunggah konfigurasi ke GitHub Environment '${ENV}'...${NC}"

  # Set variable
  gh variable set ANDROID_RESEARCH_KEY_ALIAS --repo "$APP_REPO" --env "$ENV" --body "$KEY_ALIAS"

  # Set secrets
  base64 < "$KEY_PATH" | tr -d '\n' | \
    gh secret set ANDROID_RESEARCH_KEYSTORE_BASE64 --repo "$APP_REPO" --env "$ENV" --app actions

  printf '%s' "$RESEARCH_PASSWORD" | \
    gh secret set ANDROID_RESEARCH_KEYSTORE_PASSWORD --repo "$APP_REPO" --env "$ENV" --app actions

  printf '%s' "$RESEARCH_PASSWORD" | \
    gh secret set ANDROID_RESEARCH_KEY_PASSWORD --repo "$APP_REPO" --env "$ENV" --app actions

  echo -e "${GREEN}[OK] Environment '${ENV}' selesai dikonfigurasi.${NC}"
done

echo
echo -e "${BOLD}${GREEN}=== Verifikasi Konfigurasi di GitHub ===${NC}"
for ENV in "${ENVIRONMENTS[@]}"; do
  echo -e "\n${BOLD}Environment: ${ENV}${NC}"
  echo "--- Variables ---"
  gh variable list --repo "$APP_REPO" --env "$ENV" || true
  echo "--- Secrets ---"
  gh secret list --repo "$APP_REPO" --env "$ENV" --app actions || true
done

echo
echo -e "${BOLD}${GREEN}=== Berhasil! ===${NC}"
echo -e "1. File keystore lokal tersimpan di: ${BOLD}$KEY_PATH${NC} (Backup file ini dengan aman!)."
echo -e "2. Simpan password keystore Anda di Password Manager."
echo -e "3. Sekarang workflow Research Staging Release akan otomatis menggunakan kunci penandatangan yang persisten dan konsisten."
