#!/usr/bin/env bash
# =====================================================================
#  Aztec Node — RU/EN interactive installer/runner (Docker-based)
#  Uses the requested ASCII logo. Bilingual menus & prompts.
#  Target: Ubuntu/Debian (apt). Requires sudo privileges for installs.
#  Version: 1.4.1
# =====================================================================
set -Eeuo pipefail

# -----------------------------
# Branding / Logo (keep as requested)
# -----------------------------
display_logo() {
  cat <<'EOF'
 _   _           _  _____      
| \ | |         | ||____ |     
|  \| | ___   __| |    / /_ __ 
| . ` |/ _ \ / _` |    \ \ '__|
| |\  | (_) | (_| |.___/ / |   
\_| \_/\___/ \__,_|\____/|_|
          Aztec
     Канал: @NodesN3R
EOF
}

# -----------------------------
# Colors (robust)
# -----------------------------
clrGreen=$'\033[0;32m'
clrCyan=$'\033[0;36m'
clrBlue=$'\033[0;34m'
clrRed=$'\033[0;31m'
clrYellow=$'\033[1;33m'
clrMag=$'\033[1;35m'
clrReset=$'\033[0m'
clrBold=$'\033[1m'
clrDim=$'\033[2m'

ok()    { echo -e "${clrGreen}[OK]${clrReset} ${*:-}"; }
info()  { echo -e "${clrCyan}[INFO]${clrReset} ${*:-}"; }
warn()  { echo -e "${clrYellow}[WARN]${clrReset} ${*:-}"; }
err()   { echo -e "${clrRed}[ERROR]${clrReset} ${*:-}"; }
hr()    { echo -e "${clrDim}────────────────────────────────────────────────────────${clrReset}"; }

# -----------------------------
# Configurable parameters
# -----------------------------
SCRIPT_NAME="AztecNode"
SCRIPT_VERSION="1.4.1"

AZTEC_DIR="$HOME/aztec"
ENV_FILE="$AZTEC_DIR/.env"
COMPOSE_FILE="$AZTEC_DIR/docker-compose.yml"
HOST_DATA_DIR="/root/.aztec/alpha-testnet/data"  # from compose volume mapping

# Default image tag baseline (will be written into compose initially)
AZTEC_IMAGE="aztecprotocol/aztec:1.2.1"

# -----------------------------
# Language (RU/EN)
# -----------------------------
LANG_CHOICE="ru"  # default

choose_language() {
  clear; display_logo
  echo -e "\n${clrBold}${clrMag}Select language / Выберите язык${clrReset}"
  echo -e "${clrDim}1) Русский${clrReset}"
  echo -e "${clrDim}2) English${clrReset}"
  read -rp "> " ans
  case "${ans:-}" in
    2) LANG_CHOICE="en" ;;
    *) LANG_CHOICE="ru" ;;
  esac
}

tr() {
  # safe even with set -u
  local k="${1-}"
  [[ -z "$k" ]] && return 0
  case "$LANG_CHOICE" in
    en)
      case "$k" in
        root_enabled) echo "• Root Access Enabled ✔" ;;
        updating) echo "Updating packages..." ;;
        installing_deps) echo "Installing base dependencies..." ;;
        deps_done) echo "Base dependencies installed" ;;
        docker_setup) echo "Installing Docker (engine + compose plugin)..." ;;
        docker_done) echo "Docker installed" ;;
        ufw_setup) echo "Configuring firewall (UFW)..." ;;
        ufw_warn_enable) echo "UFW will be enabled; ensure SSH (22) is allowed to avoid lockout." ;;
        ufw_done) echo "Firewall rules applied" ;;
        make_dir) echo "Creating and entering ./aztec directory" ;;
        ask_eth_rpc) echo "Enter Ethereum Sepolia RPC URL (ETHEREUM_RPC_URL):" ;;
        ask_beacon) echo "Enter Consensus Beacon RPC URL (CONSENSUS_BEACON_URL):" ;;
        ask_priv) echo "Enter VALIDATOR_PRIVATE_KEYS (0x-prefixed private key):" ;;
        ask_coinbase) echo "Enter COINBASE (your L1 address):" ;;
        ask_p2p) echo "Enter P2P_IP (your public IP; leave blank to auto-detect):" ;;
        env_saved) echo ".env saved" ;;
        compose_saved) echo "docker-compose.yml saved" ;;
        starting) echo "Starting Aztec node (docker compose up -d)..." ;;
        started) echo "Aztec node started" ;;
        restarting) echo "Restarting Aztec node..." ;;
        restarted) echo "Aztec node restarted" ;;
        logs_hint) echo "Showing live logs (last 1000 lines). Press Ctrl+C to stop viewing." ;;
        menu_title) echo "Aztec Node — Installer & Manager" ;;
        m1_bootstrap) echo "One-click setup: update packages, deps, Docker & UFW" ;;
        m2_create) echo "Create ./aztec, fill .env, and write docker-compose.yml" ;;
        m3_start) echo "Start node (docker compose up -d)" ;;
        m4_restart) echo "Restart node (docker compose restart)" ;;
        m4_logs) echo "Follow logs" ;;
        m5_sync) echo "Run sync status check (Cerberus-Node)" ;;
        m6_rpc) echo "Check your RPC health" ;;
        m7_remove) echo "Remove node, images & data (FULL)" ;;
        m8_update) echo "Update node version (edit image tag)" ;;
        m9_showver) echo "Show node version (from compose)" ;;
        m10_lang) echo "Change language / Сменить язык" ;;
        m11_exit) echo "Exit" ;;
        press_enter) echo "Press Enter to return to menu..." ;;
        sync_running) echo "Running sync status script..." ;;
        rpc_running) echo "Running RPC health check..." ;;
        need_root_warn) echo "Some steps require sudo/root. You'll be prompted when needed." ;;
        docker_missing) echo "Docker is not available. Please run the one-click setup first." ;;
        remove_confirm) echo "This will stop containers, remove volumes, images and delete data. Type 'yes' to confirm:" ;;
        keep_env_q) echo "Keep .env as backup? [Y/n]:" ;;
        backup_saved) echo "Backup saved to" ;;
        removed_ok) echo "Aztec completely removed" ;;
        cancelled) echo "Cancelled" ;;
        dir_missing) echo "Directory not found" ;;
        compose_missing) echo "docker-compose.yml not found" ;;
        update_prompt) echo "Enter target Aztec image version (e.g. 1.2.1):" ;;
        update_done) echo "Compose updated and node restarted" ;;
        compose_line_missing) echo "Image line not found in compose. Aborting." ;;
        current_version) echo "Current image tag:" ;;
        not_found) echo "not found" ;;
      esac
      ;;
    *)
      case "$k" in
        root_enabled) echo "• Root Access Enabled ✔" ;;
        updating) echo "Обновляю пакеты..." ;;
        installing_deps) echo "Устанавливаю базовые зависимости..." ;;
        deps_done) echo "Базовые зависимости установлены" ;;
        docker_setup) echo "Устанавливаю Docker (движок + compose-плагин)..." ;;
        docker_done) echo "Docker установлен" ;;
        ufw_setup) echo "Настраиваю firewall (UFW)..." ;;
        ufw_warn_enable) echo "Будет включён UFW; убедитесь, что SSH (22) разрешён, иначе потеряете доступ." ;;
        ufw_done) echo "Правила файрвола применены" ;;
        make_dir) echo "Создаю и перехожу в директорию ./aztec" ;;
        ask_eth_rpc) echo "Введите Sepolia RPC (ETHEREUM_RPC_URL):" ;;
        ask_beacon) echo "Введите Beacon RPC (CONSENSUS_BEACON_URL):" ;;
        ask_priv) echo "Введите VALIDATOR_PRIVATE_KEYS (приватник с префиксом 0x):" ;;
        ask_coinbase) echo "Введите COINBASE (ваш L1 адрес):" ;;
        ask_p2p) echo "Введите P2P_IP (ваш публичный IP; оставьте пустым для автоопределения):" ;;
        env_saved) echo ".env сохранён" ;;
        compose_saved) echo "docker-compose.yml сохранён" ;;
        starting) echo "Запускаю узел (docker compose up -d)..." ;;
        started) echo "Узел запущен" ;;
        restarting) echo "Перезапускаю узел Aztec..." ;;
        restarted) echo "Узел перезапущен" ;;
        logs_hint) echo "Показываю логи (последние 1000 строк). Нажмите Ctrl+C для выхода." ;;
        menu_title) echo "Aztec Node — установщик и менеджер" ;;
        m1_bootstrap) echo "Установка необходимых утилит" ;;
        m2_create) echo "Заполнение переменных" ;;
        m3_start) echo "Запустить ноду" ;;
        m4_restart) echo "Перезапустить ноду" ;;
        m4_logs) echo "Смотреть логи" ;;
        m5_sync) echo "Проверить синхронизацию" ;;
        m6_rpc) echo "Проверить ваше RPC" ;;
        m7_remove) echo "Удалить ноду" ;;
        m8_update) echo "Обновить версию ноды" ;;
        m9_showver) echo "Показать версию ноды" ;;
        m10_lang) echo "Сменить язык / Change language" ;;
        m11_exit) echo "Выход" ;;
        press_enter) echo "Нажмите Enter для возврата в меню..." ;;
        sync_running) echo "Запускаю скрипт проверки синхронизации..." ;;
        rpc_running) echo "Запускаю проверку здоровья RPC..." ;;
        need_root_warn) echo "Некоторые шаги требуют sudo/root. Вас попросят ввести пароль при необходимости." ;;
        docker_missing) echo "Docker недоступен. Сначала выполните установку одним шагом." ;;
        remove_confirm) echo "Будут остановлены контейнеры, удалены тома, образы и данные. Введите 'yes' для подтверждения:" ;;
        keep_env_q) echo "Сохранить .env в бэкап? [Y/n]:" ;;
        backup_saved) echo "Бэкап сохранён по пути" ;;
        removed_ok) echo "Aztec полностью удалён" ;;
        cancelled) echo "Отменено" ;;
        dir_missing) echo "Каталог не найден" ;;
        compose_missing) echo "Файл docker-compose.yml не найден" ;;
        update_prompt) echo "Введите целевую версию образа Aztec (например 1.2.1):" ;;
        update_done) echo "Compose обновлён и нода перезапущена" ;;
        compose_line_missing) echo "Строка image не найдена в compose. Останавливаюсь." ;;
        current_version) echo "Текущий тег image:" ;;
        not_found) echo "не найдено" ;;
      esac
      ;;
  esac
}

# -----------------------------
# Helpers
# -----------------------------
need_sudo() {
  if [[ $(id -u) -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    err "sudo не найден. Запустите под root или установите sudo."
    exit 1
  fi
}
run() {
  if [[ $(id -u) -ne 0 ]]; then sudo bash -lc "$*"; else bash -lc "$*"; fi
}

# -----------------------------
# Update & base deps
# -----------------------------
update_and_deps() {
  echo "$(tr root_enabled)"
  info "$(tr updating)"; run "apt-get update && apt-get upgrade -y"
  info "$(tr installing_deps)"
  run "apt-get install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip ufw screen gawk"
  ok "$(tr deps_done)"
}

# -----------------------------
# Docker install (engine + compose plugin)
# -----------------------------
install_docker() {
  info "$(tr docker_setup)"; need_sudo
  if ! command -v docker >/dev/null 2>&1; then
    run "apt-get update && apt-get install -y docker.io"
  fi
  if ! docker compose version >/dev/null 2>&1; then
    run "apt-get install -y docker-compose-plugin"
  fi
  run "systemctl enable --now docker" || true
  docker --version || true
  docker compose version || true
  ok "$(tr docker_done)"
}

# -----------------------------
# Firewall (UFW)
# -----------------------------
setup_firewall() {
  info "$(tr ufw_setup)"; need_sudo
  echo "$(tr ufw_warn_enable)"
  run "apt-get install -y ufw > /dev/null 2>&1 || true"
  run "ufw allow 22"; run "ufw allow ssh"
  run "ufw allow 40400/tcp"; run "ufw allow 40400/udp"; run "ufw allow 8080"
  yes | run ufw enable || true
  run ufw reload || true
  ok "$(tr ufw_done)"
}

# -----------------------------
# One-click bootstrap (1–3 combined)
# -----------------------------
bootstrap_setup() {
  update_and_deps
  install_docker
  setup_firewall
}

# -----------------------------
# Create dir, ask .env, write compose
# -----------------------------
create_dir_and_env_and_compose() {
  info "$(tr make_dir)"; hr
  mkdir -p "$AZTEC_DIR"; cd "$AZTEC_DIR"

  local ETHEREUM_RPC_URL="" CONSENSUS_BEACON_URL="" VALIDATOR_PRIVATE_KEYS="" COINBASE="" P2P_IP=""
  if [[ -f "$ENV_FILE" ]]; then
    set -a; source "$ENV_FILE" || true; set +a
    ETHEREUM_RPC_URL="${ETHEREUM_RPC_URL:-}"; CONSENSUS_BEACON_URL="${CONSENSUS_BEACON_URL:-}"
    VALIDATOR_PRIVATE_KEYS="${VALIDATOR_PRIVATE_KEYS:-}"; COINBASE="${COINBASE:-}"; P2P_IP="${P2P_IP:-}"
  fi

  read -rp "${clrBold}$(tr ask_eth_rpc)${clrReset} ${ETHEREUM_RPC_URL:+[$ETHEREUM_RPC_URL]} " ans; ETHEREUM_RPC_URL="${ans:-${ETHEREUM_RPC_URL}}"
  read -rp "${clrBold}$(tr ask_beacon)${clrReset} ${CONSENSUS_BEACON_URL:+[$CONSENSUS_BEACON_URL]} " ans; CONSENSUS_BEACON_URL="${ans:-${CONSENSUS_BEACON_URL}}"
  read -rp "${clrBold}$(tr ask_priv)${clrReset} ${VALIDATOR_PRIVATE_KEYS:+[***hidden***]} " ans; VALIDATOR_PRIVATE_KEYS="${ans:-${VALIDATOR_PRIVATE_KEYS}}"
  read -rp "${clrBold}$(tr ask_coinbase)${clrReset} ${COINBASE:+[$COINBASE]} " ans; COINBASE="${ans:-${COINBASE}}"
  local autodetect_ip="$(curl -s https://ifconfig.me || true)" || true
  read -rp "${clrBold}$(tr ask_p2p)${clrReset} ${P2P_IP:+[$P2P_IP]} " ans; P2P_IP="${ans:-${P2P_IP:-$autodetect_ip}}"

  cat > "$ENV_FILE" <<EOF
ETHEREUM_RPC_URL=${ETHEREUM_RPC_URL}
CONSENSUS_BEACON_URL=${CONSENSUS_BEACON_URL}
VALIDATOR_PRIVATE_KEYS=${VALIDATOR_PRIVATE_KEYS}
COINBASE=${COINBASE}
P2P_IP=${P2P_IP}
EOF
  ok "$(tr env_saved)"; hr

  cat > "$COMPOSE_FILE" <<'YAML'
services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:1.2.1
    restart: unless-stopped
    network_mode: host
    environment:
      ETHEREUM_HOSTS: ${ETHEREUM_RPC_URL}
      L1_CONSENSUS_HOST_URLS: ${CONSENSUS_BEACON_URL}
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEYS: ${VALIDATOR_PRIVATE_KEYS}
      COINBASE: ${COINBASE}
      P2P_IP: ${P2P_IP}
      LOG_LEVEL: info
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - /root/.aztec/alpha-testnet/data/:/data
YAML
  ok "$(tr compose_saved)"
}

# -----------------------------
# Start node
# -----------------------------
start_node() {
  if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    err "$(tr docker_missing)"; return 1
  fi
  cd "$AZTEC_DIR"; info "$(tr starting)"; docker compose up -d; ok "$(tr started)"
}

# -----------------------------
# Restart node
# -----------------------------
restart_node() {
  if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    err "$(tr docker_missing)"; return 1
  fi
  cd "$AZTEC_DIR"
  info "$(tr restarting)"
  if ! docker compose restart; then
    warn "compose restart failed, doing down/up..."
    docker compose down || true
    docker compose up -d
  fi
  ok "$(tr restarted)"
}

# -----------------------------
# Logs
# -----------------------------
show_logs() {
  if ! command -v docker >/dev/null 2>&1; then err "$(tr docker_missing)"; return 1; fi
  cd "$AZTEC_DIR"; info "$(tr logs_hint)"; docker compose logs -fn 1000
}

# -----------------------------
# Sync status (Cerberus-Node)
# -----------------------------
run_sync_check() {
  info "$(tr sync_running)"; bash <(curl -s https://raw.githubusercontent.com/cerberus-node/aztec-network/refs/heads/main/sync-check.sh)
}

# -----------------------------
# RPC Health Check
# -----------------------------
check_rpc_health() {
  info "$(tr rpc_running)"; run "bash <(curl -Ls https://raw.githubusercontent.com/DeepPatel2412/Aztec-Tools/main/RPC%20Health%20Check)"
}

# -----------------------------
# Remove node, images & data (FULL)
# -----------------------------
remove_node() {
  if [[ ! -d "$AZTEC_DIR" ]] && ! docker ps -a --format '{{.Names}}' | grep -q '^aztec-sequencer$'; then
    warn "$(tr dir_missing): $AZTEC_DIR"; return 0; fi
  read -rp "$(tr remove_confirm) " CONF
  if [[ "$CONF" != "yes" ]]; then warn "$(tr cancelled)"; return 0; fi

  if command -v docker >/dev/null 2>&1; then
    (cd "$AZTEC_DIR" 2>/dev/null && docker compose down -v --remove-orphans) || true
    docker ps -a --filter "name=aztec" -q | xargs -r docker rm -f || true
  fi

  if [[ -f "$ENV_FILE" ]]; then
    read -rp "$(tr keep_env_q) " KEEP
    if [[ -z "$KEEP" || "$KEEP" =~ ^[Yy]$ ]]; then
      local TS; TS="$(date +%Y%m%d_%H%M%S)"; cp "$ENV_FILE" "$HOME/aztec.env.$TS.bak" && ok "$(tr backup_saved) $HOME/aztec.env.$TS.bak"
    fi
  fi

  info "Removing aztec images..."
  local IMG_IDS
  IMG_IDS=$(docker images --format '{{.Repository}} {{.ID}}' | awk '$1=="aztecprotocol/aztec"{print $2}') || true
  if [[ -n "${IMG_IDS:-}" ]]; then docker rmi -f ${IMG_IDS} || true; ok "Images removed"; else info "No aztec images found"; fi

  if [[ -d "$HOST_DATA_DIR" ]]; then info "Removing data directory: $HOST_DATA_DIR"; run "rm -rf '$HOST_DATA_DIR'"; fi
  rm -rf "$AZTEC_DIR"; ok "$(tr removed_ok)"
}

# -----------------------------
# Update node version (edit image tag)
# -----------------------------
update_node_version() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then err "$(tr compose_missing)"; return 1; fi
  cd "$AZTEC_DIR"; docker compose down || true; clear
  read -rp "$(tr update_prompt) " TARGET; TARGET="${TARGET// /}"; [[ -z "$TARGET" ]] && { err "$(tr cancelled)"; return 1; }
  if ! grep -qE '^[[:space:]]*image:[[:space:]]*aztecprotocol/aztec:' "$COMPOSE_FILE"; then err "$(tr compose_line_missing)"; return 1; fi
  awk -v tag="$TARGET" '{ if ($0 ~ /^[[:space:]]*image:[[:space:]]*aztecprotocol\/aztec:/) { sub(/aztecprotocol\/aztec:[[:alnum:]._-]+/, "aztecprotocol/aztec:" tag) } print }' "$COMPOSE_FILE" > "$COMPOSE_FILE.tmp" && mv "$COMPOSE_FILE.tmp" "$COMPOSE_FILE"
  info "Removing aztec images..."; local IMG_IDS; IMG_IDS=$(docker images --format '{{.Repository}} {{.ID}}' | awk '$1=="aztecprotocol/aztec"{print $2}') || true
  [[ -n "${IMG_IDS:-}" ]] && docker rmi -f ${IMG_IDS} || true
  docker compose up -d; ok "$(tr update_done)"
}

# -----------------------------
# Show node version (from compose)
# -----------------------------
show_node_version() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then err "$(tr compose_missing)"; return 1; fi
  local TAG
  TAG=$(grep -E 'image:[[:space:]]*aztecprotocol/aztec:' "$COMPOSE_FILE" \
        | sed -E 's/.*aztecprotocol\/aztec:([[:alnum:]._-]+).*/\1/' \
        | head -n1 || true)
  if [[ -n "${TAG:-}" ]]; then
    printf "%b%s%b %b%s%b\n" "$clrBold" "$(tr current_version)" "$clrReset" "$clrBlue" "$TAG" "$clrReset"
  else
    echo "$(tr current_version) $(tr not_found)"
  fi
}

# -----------------------------
# Main menu
# -----------------------------
main_menu() {
  choose_language
  info "$(tr need_root_warn)" || true
  while true; do
    clear; display_logo; hr
    echo -e "${clrBold}${clrMag}$(tr menu_title)${clrReset} ${clrDim}(v${SCRIPT_VERSION})${clrReset}\n"
    echo -e "${clrGreen}1)${clrReset} $(tr m1_bootstrap)"
    echo -e "${clrGreen}2)${clrReset} $(tr m2_create)"
    echo -e "${clrGreen}3)${clrReset} $(tr m3_start)"
    echo -e "${clrGreen}4)${clrReset} $(tr m4_restart)"
    echo -e "${clrGreen}5)${clrReset} $(tr m4_logs)"
    echo -e "${clrGreen}6)${clrReset} $(tr m5_sync)"
    echo -e "${clrGreen}7)${clrReset} $(tr m6_rpc)"
    echo -e "${clrGreen}8)${clrReset} $(tr m7_remove)"
    echo -e "${clrGreen}9)${clrReset} $(tr m8_update)"
    echo -e "${clrGreen}10)${clrReset} $(tr m9_showver)"
    echo -e "${clrGreen}11)${clrReset} $(tr m10_lang)"
    echo -e "${clrGreen}12)${clrReset} $(tr m11_exit)"
    hr
    read -rp "> " choice
    case "${choice:-}" in
      1) bootstrap_setup ;;
      2) create_dir_and_env_and_compose ;;
      3) start_node ;;
      4) restart_node ;;
      5) show_logs ;;
      6) run_sync_check ;;
      7) check_rpc_health ;;
      8) remove_node ;;
      9) update_node_version ;;
      10) show_node_version ;;
      11) choose_language ;;
      12) exit 0 ;;
      *) ;;
    esac
    echo -e "\n$(tr press_enter)"; read -r
  done
}

main_menu
