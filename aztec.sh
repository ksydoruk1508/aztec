#!/usr/bin/env bash
# =====================================================================
#  Aztec Node — RU/EN interactive installer/runner (Docker-based)
#  Uses the requested ASCII logo. Bilingual menus & prompts.
#  Target: Ubuntu/Debian (apt). Requires sudo privileges for installs.
#  Version: 1.5.0
# =====================================================================
set -Eeuo pipefail

# -----------------------------
# Branding / Logo
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
# Colors
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
# Config
# -----------------------------
SCRIPT_NAME="AztecNode"
SCRIPT_VERSION="1.5.0"

AZTEC_DIR="$HOME/aztec"
ENV_FILE="$AZTEC_DIR/.env"
COMPOSE_FILE="$AZTEC_DIR/docker-compose.yml"
HOST_DATA_BASE="/root/.aztec"

# текущий дефолт
DEFAULT_IMAGE_TAG="2.0.2"
DEFAULT_NETWORK="testnet"   # можно будет выбрать

# -----------------------------
# Language (RU/EN)
# -----------------------------
LANG_CHOICE="ru"

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
        ask_network) echo "Choose network: 1) testnet  2) alpha-testnet" ;;
        env_saved) echo ".env saved" ;;
        compose_saved) echo "docker-compose.yml saved" ;;
        starting) echo "Starting Aztec node..." ;;
        started) echo "Aztec node started" ;;
        restarting) echo "Restarting Aztec node..." ;;
        restarted) echo "Aztec node restarted" ;;
        logs_hint) echo "Showing live logs (last 1000 lines). Ctrl+C to exit." ;;
        menu_title) echo "Aztec Node — Installer & Manager" ;;
        m1_bootstrap) echo "Bootstrap system deps" ;;
        m2_create) echo "Create .env and compose" ;;
        m3_start) echo "Start node" ;;
        m4_restart) echo "Restart node (apply .env)" ;;
        m4_logs) echo "Follow logs" ;;
        m5_sync) echo "Check sync" ;;
        m6_rpc) echo "Check RPC health" ;;
        m7_remove) echo "Remove node (FULL)" ;;
        m8_update) echo "Update node version" ;;
        m9_showver) echo "Show node version" ;;
        m11_peerid) echo "Show Peer ID" ;;
        m10_lang) echo "Change language" ;;
        m11_exit) echo "Exit" ;;
        press_enter) echo "Press Enter to return to menu..." ;;
        sync_running) echo "Running sync status..." ;;
        rpc_running) echo "Running RPC health check..." ;;
        need_root_warn) echo "Some steps require sudo/root. You'll be prompted when needed." ;;
        docker_missing) echo "Docker not available. Run bootstrap first." ;;
        remove_confirm) echo "This will stop containers, remove volumes, images and data. Type 'yes' to confirm:" ;;
        keep_env_q) echo "Keep .env backup? [Y/n]:" ;;
        backup_saved) echo "Backup saved to" ;;
        removed_ok) echo "Aztec removed" ;;
        cancelled) echo "Cancelled" ;;
        dir_missing) echo "Directory not found" ;;
        compose_missing) echo "docker-compose.yml not found" ;;
        update_prompt_ver) echo "Enter target image version (e.g. 2.0.2):" ;;
        update_prompt_net) echo "Choose network for update: 1) testnet  2) alpha-testnet" ;;
        update_done) echo "Compose updated and node restarted" ;;
        current_version) echo "Current image tag:" ;;
        not_found) echo "not found" ;;
        peerid_fetch) echo "Extracting Peer ID from logs..." ;;
        peerid_label) echo "Peer ID:" ;;
        peerid_notfound) echo "Peer ID not found yet." ;;
        12_rpcmenu) echo "Change RPC" ;;
        rpc_eth_prompt) echo "New Sepolia RPC (ETHEREUM_RPC_URL):" ;;
        rpc_beacon_prompt) echo "New Sepolia Beacon RPC (CONSENSUS_BEACON_URL):" ;;
        rpc_updated) echo "RPC updated" ;;
        rpc_cancelled) echo "Empty input. No changes." ;;
        rpc_menu_title) echo "RPC change" ;;
        rpc_menu_1) echo "Change Sepolia RPC" ;;
        rpc_menu_2) echo "Change Sepolia Beacon RPC URL" ;;
        rpc_menu_back) echo "Back" ;;
      esac
      ;;
    *)
      case "$k" in
        root_enabled) echo "• Root Access Enabled ✔" ;;
        updating) echo "Обновляю пакеты..." ;;
        installing_deps) echo "Ставлю зависимости..." ;;
        deps_done) echo "Готово" ;;
        docker_setup) echo "Ставлю Docker и compose..." ;;
        docker_done) echo "Docker установлен" ;;
        ufw_setup) echo "Настраиваю UFW..." ;;
        ufw_warn_enable) echo "UFW будет включен. Убедись, что порт 22 открыт, иначе потеряешь доступ." ;;
        ufw_done) echo "Правила применены" ;;
        make_dir) echo "Создаю каталог ./aztec и перехожу в него" ;;
        ask_eth_rpc) echo "Введите Sepolia RPC (ETHEREUM_RPC_URL):" ;;
        ask_beacon) echo "Введите Beacon RPC (CONSENSUS_BEACON_URL):" ;;
        ask_priv) echo "Введите VALIDATOR_PRIVATE_KEYS (с префиксом 0x):" ;;
        ask_coinbase) echo "Введите COINBASE (ваш L1 адрес):" ;;
        ask_p2p) echo "Введите P2P_IP (публичный IP, можно пусто для авто):" ;;
        ask_network) echo "Выберите сеть: 1) testnet  2) alpha-testnet" ;;
        env_saved) echo ".env сохранен" ;;
        compose_saved) echo "docker-compose.yml сохранен" ;;
        starting) echo "Запускаю ноду..." ;;
        started) echo "Нода запущена" ;;
        restarting) echo "Перезапускаю ноду..." ;;
        restarted) echo "Нода перезапущена" ;;
        logs_hint) echo "Показываю логи (1000 строк). Ctrl+C для выхода." ;;
        menu_title) echo "Aztec Node — установщик и менеджер" ;;
        m1_bootstrap) echo "Установка утилит" ;;
        m2_create) echo "Создать .env и compose" ;;
        m3_start) echo "Запустить ноду" ;;
        m4_restart) echo "Перезапустить ноду" ;;
        m4_logs) echo "Смотреть логи" ;;
        m5_sync) echo "Проверить синхронизацию" ;;
        m6_rpc) echo "Проверить RPC" ;;
        m7_remove) echo "Удалить ноду (полностью)" ;;
        m8_update) echo "Обновить версию ноды" ;;
        m9_showver) echo "Показать версию" ;;
        m11_peerid) echo "Показать Peer ID" ;;
        m10_lang) echo "Сменить язык" ;;
        m11_exit) echo "Выход" ;;
        press_enter) echo "Enter для возврата в меню..." ;;
        sync_running) echo "Запускаю проверку синхронизации..." ;;
        rpc_running) echo "Запускаю проверку RPC..." ;;
        need_root_warn) echo "Некоторые шаги требуют sudo/root." ;;
        docker_missing) echo "Docker недоступен. Сначала установи зависимости." ;;
        remove_confirm) echo "Будут удалены контейнеры, образы, тома и данные. Введи yes для подтверждения:" ;;
        keep_env_q) echo "Сохранить .env в бэкап? [Y/n]:" ;;
        backup_saved) echo "Бэкап сохранен в" ;;
        removed_ok) echo "Aztec удален" ;;
        cancelled) echo "Отменено" ;;
        dir_missing) echo "Каталог не найден" ;;
        compose_missing) echo "Файл docker-compose.yml не найден" ;;
        update_prompt_ver) echo "Введите версию образа (например 2.0.2):" ;;
        update_prompt_net) echo "Выберите сеть для обновления: 1) testnet  2) alpha-testnet" ;;
        update_done) echo "Compose обновлен и нода перезапущена" ;;
        current_version) echo "Текущий тег:" ;;
        not_found) echo "не найдено" ;;
        peerid_fetch) echo "Ищу Peer ID в логах..." ;;
        peerid_label) echo "Peer ID:" ;;
        peerid_notfound) echo "Peer ID пока не найден." ;;
        m12_rpcmenu) echo "Сменить RPC" ;;
        rpc_eth_prompt) echo "Новый Sepolia RPC (ETHEREUM_RPC_URL):" ;;
        rpc_beacon_prompt) echo "Новый Sepolia Beacon RPC (CONSENSUS_BEACON_URL):" ;;
        rpc_updated) echo "RPC обновлен" ;;
        rpc_cancelled) echo "Пусто. Изменений нет." ;;
        rpc_menu_title) echo "Смена RPC" ;;
        rpc_menu_1) echo "Сменить Sepolia RPC" ;;
        rpc_menu_2) echo "Сменить Sepolia Beacon RPC URL" ;;
        rpc_menu_back) echo "Назад" ;;
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
# Compose writer by template
# -----------------------------
write_compose() {
  local image_tag="$1"
  local network="$2"
  local host_data_dir="$HOST_DATA_BASE/$network/data"

  mkdir -p "$AZTEC_DIR"
  cat > "$COMPOSE_FILE" <<YAML
services:
  aztec-node:
    container_name: aztec-sequencer
    image: aztecprotocol/aztec:${image_tag}
    restart: unless-stopped
    network_mode: host
    environment:
      ETHEREUM_HOSTS: \${ETHEREUM_RPC_URL}
      L1_CONSENSUS_HOST_URLS: \${CONSENSUS_BEACON_URL}
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEYS: \${VALIDATOR_PRIVATE_KEYS}
      COINBASE: \${COINBASE}
      P2P_IP: \${P2P_IP}
      LOG_LEVEL: info
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network ${network} --node --archiver --sequencer'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - ${host_data_dir}:/data
YAML
  sanitize_yaml "$COMPOSE_FILE"
  ok "$(tr compose_saved)"
}

# безопасно обновляет/добавляет переменную в .env
update_env_var() {
  local key="$1"; shift
  local val="$*"
  mkdir -p "$(dirname "$ENV_FILE")"
  touch "$ENV_FILE"
  # убрать CRLF
  sed -i 's/\r$//' "$ENV_FILE" || true
  # экранируем спецсимволы для sed (& и разделитель)
  local esc; esc=$(printf '%s' "$val" | sed -e 's/[&@]/\\&/g')
  if grep -qE "^${key}=" "$ENV_FILE"; then
    sed -i -E "s@^${key}=.*@${key}=${esc}@" "$ENV_FILE"
  else
    printf "%s=%s\n" "$key" "$val" >> "$ENV_FILE"
  fi
}

sanitize_yaml() {
  [[ -f "$1" ]] && sed -i 's/\r$//' "$1"
}

choose_network() {
  local def="${1:-testnet}" ans
  { echo "$(tr ask_network)"; printf "> "; } >/dev/tty
  IFS= read -r ans </dev/tty
  ans="${ans//[$'\t\r\n ']/}"
  case "${ans:-}" in
    2|alpha|alpha-testnet) echo "alpha-testnet" ;;
    ""|1|testnet)          echo "testnet" ;;
    *)                     echo "$def" ;;
  esac
}

# -----------------------------
# Create dir, ask .env, write compose
# -----------------------------
create_dir_env_compose() {
  info "$(tr make_dir)"; hr
  mkdir -p "$AZTEC_DIR"; cd "$AZTEC_DIR"

  local ETHEREUM_RPC_URL="" CONSENSUS_BEACON_URL="" VALIDATOR_PRIVATE_KEYS="" COINBASE="" P2P_IP=""
  if [[ -f "$ENV_FILE" ]]; then
  while IFS= read -r line; do
    [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || continue
    key="${line%%=*}"; val="${line#*=}"
    printf -v "$key" '%s' "$val"
  done < "$ENV_FILE"
  fi

  read -rp "${clrBold}$(tr ask_eth_rpc)${clrReset} ${ETHEREUM_RPC_URL:+[$ETHEREUM_RPC_URL]} " ans; ETHEREUM_RPC_URL="${ans:-${ETHEREUM_RPC_URL:-}}"
  read -rp "${clrBold}$(tr ask_beacon)${clrReset} ${CONSENSUS_BEACON_URL:+[$CONSENSUS_BEACON_URL]} " ans; CONSENSUS_BEACON_URL="${ans:-${CONSENSUS_BEACON_URL:-}}"
  read -rp "${clrBold}$(tr ask_priv)${clrReset} ${VALIDATOR_PRIVATE_KEYS:+[***hidden***]} " ans; VALIDATOR_PRIVATE_KEYS="${ans:-${VALIDATOR_PRIVATE_KEYS:-}}"
  read -rp "${clrBold}$(tr ask_coinbase)${clrReset} ${COINBASE:+[$COINBASE]} " ans; COINBASE="${ans:-${COINBASE:-}}"
  local autodetect_ip="$(curl -s https://ifconfig.me || true)" || true
  read -rp "${clrBold}$(tr ask_p2p)${clrReset} ${P2P_IP:+[$P2P_IP]} " ans; P2P_IP="${ans:-${P2P_IP:-$autodetect_ip}}"

  local NET; NET="$(choose_network "$DEFAULT_NETWORK")"

  cat > "$ENV_FILE" <<EOF
ETHEREUM_RPC_URL=${ETHEREUM_RPC_URL}
CONSENSUS_BEACON_URL=${CONSENSUS_BEACON_URL}
VALIDATOR_PRIVATE_KEYS=${VALIDATOR_PRIVATE_KEYS}
COINBASE=${COINBASE}
P2P_IP=${P2P_IP}
AZTEC_NETWORK=${NET}
EOF
  ok "$(tr env_saved)"; hr

  write_compose "$DEFAULT_IMAGE_TAG" "$NET"
}

# -----------------------------
# Start / restart / logs
# -----------------------------
start_node() {
  if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    err "$(tr docker_missing)"; return 1
  fi
  cd "$AZTEC_DIR"; info "$(tr starting)"; docker compose up -d; ok "$(tr started)"
}

restart_node() {
  if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
    err "$(tr docker_missing)"; return 1
  fi
  cd "$AZTEC_DIR" || { err "Aztec dir not found"; return 1; }
  info "$(tr restarting)"; docker compose up -d --force-recreate --no-deps aztec-node; ok "$(tr restarted)"
}

show_logs() {
  if ! command -v docker >/dev/null 2>&1; then err "$(tr docker_missing)"; return 1; fi
  cd "$AZTEC_DIR"; info "$(tr logs_hint)"; docker compose logs -fn 1000
}

# -----------------------------
# Sync / RPC
# -----------------------------
run_sync_check() { info "$(tr sync_running)"; bash <(curl -s https://raw.githubusercontent.com/cerberus-node/aztec-network/refs/heads/main/sync-check.sh); }
check_rpc_health() { info "$(tr rpc_running)"; run "bash <(curl -Ls https://raw.githubusercontent.com/DeepPatel2412/Aztec-Tools/main/RPC%20Health%20Check)"; }

# -----------------------------
# Peer ID
# -----------------------------
view_peer_id() {
  if ! command -v docker >/dev/null 2>&1; then err "$(tr docker_missing)"; return 1; fi
  info "$(tr peerid_fetch)"
  local cid pid
  cid=$(docker ps -q --filter "name=aztec" | head -1 || true)
  [[ -z "${cid:-}" ]] && { warn "aztec container not running"; return 1; }
  pid=$(docker logs "$cid" 2>&1 | grep -m 1 -ai 'DiscV5 service started' | grep -o '"peerId":"[^"]*"' | cut -d'"' -f4 || true)
  if [[ -n "${pid:-}" ]]; then
    printf "%b%s%b %b%s%b\n" "$clrBold" "$(tr peerid_label)" "$clrReset" "$clrBlue" "$pid" "$clrReset"
  else
    warn "$(tr peerid_notfound)"
  fi
}

change_rpc_menu() {
  if [[ ! -f "$ENV_FILE" ]]; then
    warn "Файл .env не найден: $ENV_FILE"
    return 1
  fi
  while true; do
    clear; display_logo; hr
    echo -e "${clrBold}${clrMag}$(tr rpc_menu_title)${clrReset}\n"
    echo -e "${clrGreen}1)${clrReset} $(tr rpc_menu_1)"
    echo -e "${clrGreen}2)${clrReset} $(tr rpc_menu_2)"
    echo -e "${clrGreen}3)${clrReset} $(tr rpc_menu_back)"
    hr
    read -rp "> " sub
    case "${sub:-}" in
      1)
        read -rp "$(tr rpc_eth_prompt) " NEWRPC
        if [[ -z "${NEWRPC// }" ]]; then
          warn "$(tr rpc_cancelled)"; echo -e "\n$(tr press_enter)"; read -r; continue
        fi
        update_env_var "ETHEREUM_RPC_URL" "$NEWRPC"
        ok "$(tr rpc_updated)"; restart_node
        echo -e "\n$(tr press_enter)"; read -r
        ;;
      2)
        read -rp "$(tr rpc_beacon_prompt) " NEWB
        if [[ -z "${NEWB// }" ]]; then
          warn "$(tr rpc_cancelled)"; echo -e "\n$(tr press_enter)"; read -r; continue
        fi
        update_env_var "CONSENSUS_BEACON_URL" "$NEWB"
        ok "$(tr rpc_updated)"; restart_node
        echo -e "\n$(tr press_enter)"; read -r
        ;;
      3) break ;;
      *) ;;
    esac
  done
}

# -----------------------------
# Remove node
# -----------------------------
remove_node() {
  if [[ ! -d "$AZTEC_DIR" ]] && ! docker ps -a --format '{{.Names}}' | grep -q '^aztec-sequencer$'; then
    warn "$(tr dir_missing): $AZTEC_DIR"; return 0; fi
  read -rp "$(tr remove_confirm) " CONF
  if [[ "$CONF" != "yes" ]]; then warn "$(tr cancelled)"; return 0; fi

  if command -v docker >/dev/null 2>&1; then
    (cd "$AZTEC_DIR" 2>/dev/null && docker compose down -v --remove-orphans) || true
    docker ps -a --filter "name=aztec" -q | xargs -r docker rm -f || true
    local IMG_IDS; IMG_IDS=$(docker images --format '{{.Repository}} {{.ID}}' | awk '$1=="aztecprotocol/aztec"{print $2}') || true
    [[ -n "${IMG_IDS:-}" ]] && docker rmi -f ${IMG_IDS} || true
  fi

  if [[ -f "$ENV_FILE" ]]; then
    read -rp "$(tr keep_env_q) " KEEP
    if [[ -z "$KEEP" || "$KEEP" =~ ^[Yy]$ ]]; then
      local TS; TS="$(date +%Y%m%d_%H%M%S)"; cp "$ENV_FILE" "$HOME/aztec.env.$TS.bak" && ok "$(tr backup_saved) $HOME/aztec.env.$TS.bak"
    fi
  fi

  local NET="testnet"
  [[ -f "$ENV_FILE" ]] && NET="$(grep -E '^AZTEC_NETWORK=' "$ENV_FILE" | cut -d= -f2- || echo testnet)"
  local DATA_DIR="$HOST_DATA_BASE/$NET/data"
  [[ -d "$DATA_DIR" ]] && info "Removing data dir $DATA_DIR" && run "rm -rf '$DATA_DIR'"

  rm -rf "$AZTEC_DIR"; ok "$(tr removed_ok)"
}

# -----------------------------
# Update node version + ask network
# -----------------------------
update_node_version() {
  if [[ ! -f "$COMPOSE_FILE" ]]; then err "$(tr compose_missing)"; return 1; fi
  cd "$AZTEC_DIR"; docker compose down || true; clear

  # 1) спросить версию
  read -rp "$(tr update_prompt_ver) " TARGET
  TARGET="${TARGET//[$'\t\r\n ']/}"
  [[ -z "$TARGET" ]] && TARGET="$DEFAULT_IMAGE_TAG"

  # 2) спросить сеть
  echo "$(tr update_prompt_net)"
  read -rp "> " ans
  case "${ans:-}" in
    2|alpha|alpha-testnet) NET_SEL="alpha-testnet" ;;
    ""|1|testnet) NET_SEL="testnet" ;;
    *) NET_SEL="$DEFAULT_NETWORK" ;;
  esac

  # 3) перегенерируем compose из чистого шаблона
  write_compose "$TARGET" "$NET_SEL"

  # 4) чистим возможные мусорные байты и CRLF (на всякий)
  sanitize_yaml "$COMPOSE_FILE"

  # 5) сносим старые образы aztec и запускаем
  info "Removing aztec images..."
  local IMG_IDS; IMG_IDS=$(docker images --format '{{.Repository}} {{.ID}}' | awk '$1=="aztecprotocol/aztec"{print $2}') || true
  [[ -n "${IMG_IDS:-}" ]] && docker rmi -f ${IMG_IDS} || true

  docker compose up -d
  ok "$(tr update_done)"
}

# -----------------------------
# Show node version
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
    echo -e "${clrGreen}8)${clrReset} $(tr m12_rpcmenu)"
    echo -e "${clrGreen}9)${clrReset} $(tr m7_remove)"
    echo -e "${clrGreen}10)${clrReset} $(tr m8_update)"
    echo -e "${clrGreen}11)${clrReset} $(tr m9_showver)"
    echo -e "${clrGreen}12)${clrReset} $(tr m11_peerid)"
    echo -e "${clrGreen}13)${clrReset} $(tr m10_lang)"
    echo -e "${clrGreen}0)${clrReset} $(tr m11_exit)"
    hr
    read -rp "> " choice
    case "${choice:-}" in
      1) update_and_deps ;;
      2) create_dir_env_compose ;;
      3) start_node ;;
      4) restart_node ;;
      5) show_logs ;;
      6) run_sync_check ;;
      7) check_rpc_health ;;
      8) change_rpc_menu ;;
      9) remove_node ;;
      10) update_node_version ;;
      11) show_node_version ;;
      12) view_peer_id ;;
      13) choose_language ;;
      0) exit 0 ;;
      *) ;;
    esac
    echo -e "\n$(tr press_enter)"; read -r
  done
}

main_menu
