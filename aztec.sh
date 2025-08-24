#!/usr/bin/env bash
# =====================================================================
#  Aztec Node — RU/EN interactive installer/runner (Docker-based)
#  Uses the requested ASCII logo. Bilingual menus & prompts.
#  Target: Ubuntu/Debian (apt). Requires sudo privileges for installs.
#  Version: 1.2.0
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
# Configurable parameters
# -----------------------------
SCRIPT_NAME="AztecNode"
SCRIPT_VERSION="1.2.0"

# Paths
AZTEC_DIR="$HOME/aztec"
ENV_FILE="$AZTEC_DIR/.env"
COMPOSE_FILE="$AZTEC_DIR/docker-compose.yml"

# Docker image tag (from snippet)
AZTEC_IMAGE="aztecprotocol/aztec:1.2.1"

# -----------------------------
# Colors (toggleable)
# -----------------------------
COLOR_ENABLED=1
clrGreen='' ; clrCyan='' ; clrRed='' ; clrYellow='' ; clrReset='' ; clrBold=''
apply_colors() {
  if [[ "$COLOR_ENABLED" -eq 1 ]]; then
    clrGreen='[0;32m'
    clrCyan='[0;36m'
    clrRed='[0;31m'
    clrYellow='[1;33m'
    clrReset='[0m'
    clrBold='[1m'
  else
    clrGreen='' ; clrCyan='' ; clrRed='' ; clrYellow='' ; clrReset='' ; clrBold=''
  fi
}
apply_colors

ok()    { echo -e "${clrGreen}[OK] $1${clrReset}"; }
info()  { echo -e "${clrCyan}[INFO] $1${clrReset}"; }
warn()  { echo -e "${clrYellow}[WARN] $1${clrReset}"; }
err()   { echo -e "${clrRed}[ERROR] $1${clrReset}"; }

# -----------------------------
# Language (RU/EN)
# -----------------------------
LANG_CHOICE="ru"  # default

choose_language() {
  clear; display_logo
  echo -e "
${clrBold}Select language / Выберите язык:${clrReset}"
  echo "1) Русский"
  echo "2) English"
  read -rp "> " ans
  case "$ans" in
    2) LANG_CHOICE="en" ;;
    *) LANG_CHOICE="ru" ;;
  esac
}

tr() {
  # $1 = key
  local k="$1"
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
        m1_bootstrap) echo "One‑click setup: update packages, deps, Docker & UFW" ;;
        m2_create) echo "Create ./aztec, fill .env, and write docker-compose.yml" ;;
        m3_start) echo "Start node (docker compose up -d)" ;;
        m4_restart) echo "Restart node (docker compose restart)" ;;
        m4_logs) echo "Follow logs" ;;
        m5_sync) echo "Run sync status check (Cerberus-Node)" ;;
        m6_rpc) echo "Check your RPC health" ;;
        m7_remove) echo "Remove node & data" ;;
        m8_lang) echo "Change language / Сменить язык" ;;
        m9_colors) echo "Toggle colors On/Off" ;;
        m10_exit) echo "Exit" ;;
        press_enter) echo "Press Enter to return to menu..." ;;
        sync_running) echo "Running sync status script..." ;;
        rpc_running) echo "Running RPC health check..." ;;
        need_root_warn) echo "Some steps require sudo/root. You'll be prompted when needed." ;;
        docker_missing) echo "Docker is not available. Please run the one‑click setup first." ;;
        remove_confirm) echo "This will stop and remove containers, volumes and delete the ./aztec folder. Type 'yes' to confirm:" ;;
        keep_env_q) echo "Keep .env as backup? [Y/n]:" ;;
        backup_saved) echo "Backup saved to" ;;
        removed_ok) echo "Node and data removed" ;;
        cancelled) echo "Cancelled" ;;
        dir_missing) echo "Directory not found" ;;
        colors_on) echo "Colors: ENABLED" ;;
        colors_off) echo "Colors: DISABLED" ;;
        *) echo "$k" ;;
      esac
      ;;
    *)
      case "$k" in
        root_enabled) echo "• Root Access Enabled ✔" ;;
        updating) echo "Обновляю пакеты..." ;;
        installing_deps) echo "Устанавливаю базовые зависимости..." ;;
        deps_done) echo "Базовые зависимости установлены" ;;
        docker_setup) echo "Устанавливаю Docker (движок + compose‑плагин)..." ;;
        docker_done) echo "Docker установлен" ;;
        ufw_setup) echo "Настраиваю firewall (UFW)..." ;;
        ufw_warn_enable) echo "Будет включён UFW; убедитесь, что SSH (22) разрешён, иначе потеряете доступ." ;;
        ufw_done) echo "Правила файрвола применены" ;;
        make_dir) echo "Создаю и перехожу в директорию ./aztec" ;;
        ask_eth_rpc) echo "Введите Sepolia RPC (ETHEREUM_RPC_URL):" ;;
        ask_beacon) echo "Введите Beacon RPC (CONSЕНSUS_BEACON_URL):" ;;
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
        m1_bootstrap) echo "Установить за раз: обновление, зависимости, Docker и UFW" ;;
        m2_create) echo "Создать ./aztec, заполнить .env и записать docker-compose.yml" ;;
        m3_start) echo "Запустить узел (docker compose up -d)" ;;
        m4_restart) echo "Перезапустить узел \(docker compose restart\)" ;;
        m4_logs) echo "Смотреть логи" ;;
        m5_sync) echo "Проверить синхронизацию (скрипт Cerberus‑Node)" ;;
        m6_rpc) echo "Проверить здоровье вашего RPC" ;;
        m7_remove) echo "Удалить ноду и данные" ;;
        m8_lang) echo "Сменить язык / Change language" ;;
        m9_colors) echo "Переключить цвета (вкл/выкл)" ;;
        m10_exit) echo "Выход" ;;
        press_enter) echo "Нажмите Enter для возврата в меню..." ;;
        sync_running) echo "Запускаю скрипт проверки синхронизации..." ;;
        rpc_running) echo "Запускаю проверку здоровья RPC..." ;;
        need_root_warn) echo "Некоторые шаги требуют sudo/root. Вас попросят ввести пароль при необходимости." ;;
        docker_missing) echo "Docker недоступен. Сначала выполните установку одним шагом." ;;
        remove_confirm) echo "Будет остановлен и удалён контейнер с томами и удалена папка ./aztec. Введите 'yes' для подтверждения:" ;;
        keep_env_q) echo "Сохранить .env в бэкап? [Y/n]:" ;;
        backup_saved) echo "Бэкап сохранён по пути" ;;
        removed_ok) echo "Нода и данные удалены" ;;
        cancelled) echo "Отменено" ;;
        dir_missing) echo "Каталог не найден" ;;
        colors_on) echo "Цвета: ВКЛ" ;;
        colors_off) echo "Цвета: ВЫКЛ" ;;
        *) echo "$k" ;;
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
  # Run with sudo when necessary
  if [[ $(id -u) -ne 0 ]]; then sudo bash -lc "$*"; else bash -lc "$*"; fi
}

toggle_colors() {
  if [[ "$COLOR_ENABLED" -eq 1 ]]; then COLOR_ENABLED=0; apply_colors; info "$(tr colors_off)"; else COLOR_ENABLED=1; apply_colors; info "$(tr colors_on)"; fi
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
  # Try distro packages first (Ubuntu 22.04+ has docker.io + docker-compose-plugin)
  if ! command -v docker >/dev/null 2>&1; then
    run "apt-get update && apt-get install -y docker.io"
  fi
  if ! docker compose version >/dev/null 2>&1; then
    run "apt-get install -y docker-compose-plugin"
  fi
  # Enable & start
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
  run "ufw allow 22"
  run "ufw allow ssh"
  # Sequencer ports
  run "ufw allow 40400/tcp"
  run "ufw allow 40400/udp"
  run "ufw allow 8080"
  # Enable & reload
  yes | run ufw enable || true
  run ufw reload || true
  ok "$(tr ufw_done)"
}

# -----------------------------
# One‑click bootstrap (1–3 combined)
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
  info "$(tr make_dir)"
  mkdir -p "$AZTEC_DIR"
  cd "$AZTEC_DIR"

  # Read existing values if any
  local ETHEREUM_RPC_URL="" CONSENSUS_BEACON_URL="" VALIDATOR_PRIVATE_KEYS="" COINBASE="" P2P_IP=""
  if [[ -f "$ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    set -a; source "$ENV_FILE" || true; set +a
    ETHEREUM_RPC_URL="${ETHEREUM_RPC_URL:-}"
    CONSENSUS_BEACON_URL="${CONSENSUS_BEACON_URL:-}"
    VALIDATOR_PRIVATE_KEYS="${VALIDATOR_PRIVATE_KEYS:-}"
    COINBASE="${COINBASE:-}"
    P2P_IP="${P2P_IP:-}"
  fi

  read -rp "$(tr ask_eth_rpc) ${ETHEREUM_RPC_URL:+[$ETHEREUM_RPC_URL]} " ans; ETHEREUM_RPC_URL="${ans:-${ETHEREUM_RPC_URL}}"
  read -rp "$(tr ask_beacon) ${CONSENSUS_BEACON_URL:+[$CONSENSUS_BEACON_URL]} " ans; CONSENSUS_BEACON_URL="${ans:-${CONSENSUS_BEACON_URL}}"
  read -rp "$(tr ask_priv) ${VALIDATOR_PRIVATE_KEYS:+[***hidden***]} " ans; VALIDATOR_PRIVATE_KEYS="${ans:-${VALIDATOR_PRIVATE_KEYS}}"
  read -rp "$(tr ask_coinbase) ${COINBASE:+[$COINBASE]} " ans; COINBASE="${ans:-${COINBASE}}"
  local autodetect_ip="$(curl -s https://ifconfig.me || true)" || true
  read -rp "$(tr ask_p2p) ${P2P_IP:+[$P2P_IP]} " ans; P2P_IP="${ans:-${P2P_IP:-$autodetect_ip}}"

  cat > "$ENV_FILE" <<EOF
ETHEREUM_RPC_URL=${ETHEREUM_RPC_URL}
CONSENSUS_BEACON_URL=${CONSENSUS_BEACON_URL}
VALIDATOR_PRIVATE_KEYS=${VALIDATOR_PRIVATE_KEYS}
COINBASE=${COINBASE}
P2P_IP=${P2P_IP}
EOF
  ok "$(tr env_saved)"

  # docker-compose.yml from the spec
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
$1
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
  cd "$AZTEC_DIR"
  info "$(tr logs_hint)"
  docker compose logs -fn 1000
}

# -----------------------------
# Sync status (Cerberus-Node)
# -----------------------------
run_sync_check() {
  info "$(tr sync_running)"
  bash <(curl -s https://raw.githubusercontent.com/cerberus-node/aztec-network/refs/heads/main/sync-check.sh)
}

# -----------------------------
# RPC Health Check
# -----------------------------
check_rpc_health() {
  info "$(tr rpc_running)"
  run "bash <(curl -Ls https://raw.githubusercontent.com/DeepPatel2412/Aztec-Tools/main/RPC%20Health%20Check)"
}

# -----------------------------
# Remove node & data
# -----------------------------
remove_node() {
  if [[ ! -d "$AZTEC_DIR" ]]; then warn "$(tr dir_missing): $AZTEC_DIR"; return 0; fi
  read -rp "$(tr remove_confirm) " CONF
  if [[ "$CONF" != "yes" ]]; then warn "$(tr cancelled)"; return 0; fi
  if command -v docker >/dev/null 2>&1; then
    (cd "$AZTEC_DIR" && docker compose down -v --remove-orphans) || true
  fi
  read -rp "$(tr keep_env_q) " KEEP
  if [[ -z "$KEEP" || "$KEEP" =~ ^[Yy]$ ]]; then
    if [[ -f "$ENV_FILE" ]]; then
      local TS; TS="$(date +%Y%m%d_%H%M%S)"
      cp "$ENV_FILE" "$HOME/aztec.env.$TS.bak" && ok "$(tr backup_saved) $HOME/aztec.env.$TS.bak"
    fi
  fi
  rm -rf "$AZTEC_DIR"
  ok "$(tr removed_ok)"
}

# -----------------------------
# Main menu
# -----------------------------
main_menu() {
  choose_language
  info "$(tr need_root_warn)"
  while true; do
    clear; display_logo
    echo -e "
${clrBold}$(tr menu_title)${clrReset} — v${SCRIPT_VERSION}
"    echo "1) $(tr m1_bootstrap)"
    echo "2) $(tr m2_create)"
    echo "3) $(tr m3_start)"
    echo "4) $(tr m4_restart)"
    echo "5) $(tr m4_logs)"
    echo "6) $(tr m5_sync)"
    echo "7) $(tr m6_rpc)"
    echo "8) $(tr m7_remove)"
    echo "9) $(tr m8_lang)"
    echo "10) $(tr m9_colors)"
    echo "11) $(tr m10_exit)"
    read -rp "> " choice
    case "$choice" in      1) bootstrap_setup ;;
      2) create_dir_and_env_and_compose ;;
      3) start_node ;;
      4) restart_node ;;
      5) show_logs ;;
      6) run_sync_check ;;
      7) check_rpc_health ;;
      8) remove_node ;;
      9) choose_language ;;
      10) toggle_colors ;;
      11) exit 0 ;;
      *) ;;
    esac
    echo -e "
$(tr press_enter)"; read -r
  done
}

main_menu
