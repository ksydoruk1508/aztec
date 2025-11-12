#!/usr/bin/env bash
# Aztec — Usage Dashboard (read-only)
# Печатает размеры, статус контейнера, порты и тулчейн в цвете.
set -Eeuo pipefail
export LC_ALL=C
: "${HOME:=/root}"

# ----- Конфиг (совместим с твоим установщиком) -----
AZTEC_DIR="${AZTEC_DIR:-$HOME/aztec}"
ENV_FILE="${ENV_FILE:-$AZTEC_DIR/.env}"
COMPOSE_FILE="${COMPOSE_FILE:-$AZTEC_DIR/docker-compose.yml}"
HOST_DATA_BASE="${HOST_DATA_BASE:-/root/.aztec}"
CONTAINER_NAME="${CONTAINER_NAME:-aztec-sequencer}"   # из compose
IMAGE_REPO="${IMAGE_REPO:-aztecprotocol/aztec}"       # основной образ
PORTS=( "40400/tcp" "40400/udp" "8080/tcp" )

# ----- Цвета как на скрине -----
clrGreen=$'\033[0;32m'
clrCyan=$'\033[0;36m'
clrBlue=$'\033[0;34m'
clrRed=$'\033[0;31m'
clrYellow=$'\033[1;33m'
clrMag=$'\033[1;35m'
clrReset=$'\033[0m'
clrBold=$'\033[1m'
clrDim=$'\033[2m'
hr(){ echo -e "${clrDim}────────────────────────────────────────────────────────────${clrReset}"; }

# ----- Утилиты -----
hum(){ awk -v b="${1:-0}" '
  function H(x){u[0]="B";u[1]="KB";u[2]="MB";u[3]="GB";u[4]="TB";i=0;while(x>=1024&&i<4){x/=1024;i++}printf "%.2f%s",x,u[i]}
  BEGIN{H(b)}
'; }
b_of(){ [[ -e "$1" ]] && du -sb "$1" 2>/dev/null | awk '{print $1}' || echo 0; }
whichp(){ command -v "$1" 2>/dev/null || true; }
fsize(){ local p; p="$(whichp "$1")"; [[ -n "$p" && -f "$p" ]] && stat -c '%s' "$p" 2>/dev/null || echo 0; }
fmt_seconds(){ local s="${1:-0}"; printf "%dd %02d:%02d:%02d" "$((s/86400))" "$((s%86400/3600))" "$((s%3600/60))" "$((s%60))"; }
trim_url(){ printf "%s" "${1:-}" | sed -E 's#^(https?://)##; s#/*$##; s#(.{1,64}).*#\1…#'; }

# ----- .env / сеть / RPC -----
ENV_NET="testnet"
ENV_ETH_RPC=""
ENV_BEACON=""
if [[ -f "$ENV_FILE" ]]; then
  ENV_NET="$(sed -n 's/^AZTEC_NETWORK=//p' "$ENV_FILE" | tr -d '\r' | tail -n1 || true)"
  ENV_ETH_RPC="$(sed -n 's/^ETHEREUM_RPC_URL=//p' "$ENV_FILE" | tr -d '\r' | tail -n1 || true)"
  ENV_BEACON="$(sed -n 's/^CONSENSUS_BEACON_URL=//p' "$ENV_FILE" | tr -d '\r' | tail -n1 || true)"
  [[ -z "$ENV_NET" ]] && ENV_NET="testnet"
fi
DATA_DIR="$HOST_DATA_BASE/$ENV_NET/data"

# ----- Docker / контейнер -----
have_docker=false
docker ps >/dev/null 2>&1 && have_docker=true
CID=""
RUNNING=false
HEALTH="n/a"
CPU_PCT="0.00%"
MEM_HUM="0B"
MEM_PCT="0%"
UPTIME="-"
IMAGE_SIZE_B=0
IMAGE_TAG="-"

if $have_docker; then
  CID="$(docker ps -q --filter "name=^${CONTAINER_NAME}$" | head -1 || true)"
  if [[ -n "$CID" ]]; then
    RUNNING=true
    # docker stats
    if stats=$(docker stats --no-stream --format '{{.CPUPerc}};{{.MemUsage}};{{.MemPerc}}' "$CID" 2>/dev/null); then
      CPU_PCT="${stats%%;*}"; rest="${stats#*;}"
      MEM_HUM="${rest%%;*}"; MEM_PCT="${rest##*;}"
      # нормализуем пробелы типа "8.44GiB / 62.58GiB"
      MEM_HUM="$(echo "$MEM_HUM" | sed 's/ \//\//')"
    fi
    # health
    HEALTH="$(docker inspect --format '{{.State.Health.Status}}' "$CID" 2>/dev/null || echo n/a)"
    [[ "$HEALTH" == "<no value>" || -z "$HEALTH" ]] && HEALTH="n/a"
    # uptime
    if started=$(docker inspect --format '{{.State.StartedAt}}' "$CID" 2>/dev/null); then
      # переводим в секунды
      sec_now=$(date +%s)
      sec_started=$(date -d "$started" +%s 2>/dev/null || echo "$sec_now")
      ((sec_started>0)) && UPTIME="$(fmt_seconds $((sec_now-sec_started)))"
    fi
    # image
    img_ref="$(docker inspect --format '{{.Config.Image}}' "$CID" 2>/dev/null || true)"
    if [[ -n "$img_ref" ]]; then
      IMAGE_TAG="${img_ref#${IMAGE_REPO}:}"
      # размер образа
      IMAGE_SIZE_B="$(docker image inspect "$img_ref" --format '{{.Size}}' 2>/dev/null || echo 0)"
    fi
  fi
  # если CID пуст, попробуем выцепить тег образа из compose
  if [[ -z "$CID" && -f "$COMPOSE_FILE" ]]; then
    IMAGE_TAG="$(grep -E '^\s*image:\s*'"$IMAGE_REPO"':' "$COMPOSE_FILE" | sed -E 's/.*:([[:alnum:]._-]+)$/\1/' | head -1 || echo "-")"
    [[ -n "$IMAGE_TAG" ]] || IMAGE_TAG="-"
    if [[ "$IMAGE_TAG" != "-" ]]; then
      IMAGE_SIZE_B="$(docker image inspect "${IMAGE_REPO}:${IMAGE_TAG}" --format '{{.Size}}' 2>/dev/null || echo 0)"
    fi
  fi
fi

# ----- Порты -----
port_state(){
  local proto="${1##*/}" port="${1%/*}"
  case "$proto" in
    tcp) ss -lnt 2>/dev/null | awk '{print $4}' | awk -F':' '{print $NF}' | grep -qx "$port" && \
         echo -e "${clrGreen}listening${clrReset}" || echo -e "${clrRed}-${clrReset}" ;;
    udp) ss -lnu 2>/dev/null | awk '{print $5}' | awk -F':' '{print $NF}' | grep -qx "$port" && \
         echo -e "${clrGreen}listening${clrReset}" || echo -e "${clrRed}-${clrReset}" ;;
    *)   echo -e "${clrRed}-${clrReset}" ;;
  esac
}

# ----- Размеры -----
AZTEC_DIR_B="$(b_of "$AZTEC_DIR")"
DATA_DIR_B="$(b_of "$DATA_DIR")"

# ----- Toolchain -----
aztec_bin="$HOME/.aztec/bin/aztec"
foundry_cast="$HOME/.foundry/bin/cast"
foundry_forge="$HOME/.foundry/bin/forge"
print_tool(){
  local title="$1" ver="$2" path="$3" size_b="$4"
  echo -e "${clrBold}${title}${clrReset}:     ${clrGreen}${ver}${clrReset}"
  echo -e "  ${clrCyan}path${clrReset}:            ${clrBlue}${path:-"-"}${clrReset}"
  echo -e "  ${clrCyan}size${clrReset}:            ${clrBlue}$(hum "${size_b:-0}")${clrReset}"
  echo
}

# ====================== ВЫВОД ======================
echo -e "${clrMag}${clrBold}Aztec — Usage Dashboard${clrReset}"
hr
echo -e "${clrCyan}AZTEC_DIR${clrReset}:  ${clrBlue}${AZTEC_DIR}${clrReset}"
echo -e "${clrCyan}ENV_FILE${clrReset}:   ${clrBlue}${ENV_FILE}${clrReset}"
echo -e "${clrCyan}NETWORK${clrReset}:    ${clrBlue}${ENV_NET}${clrReset}"
if [[ -n "$ENV_ETH_RPC" ]]; then
  echo -e "${clrCyan}ETH_RPC${clrReset}:    ${clrBlue}$(trim_url "$ENV_ETH_RPC")${clrReset}"
fi
if [[ -n "$ENV_BEACON" ]]; then
  echo -e "${clrCyan}BEACON${clrReset}:     ${clrBlue}$(trim_url "$ENV_BEACON")${clrReset}"
fi
hr

echo -e "${clrBold}Диск (хост)${clrReset}:"
echo -e "  ${clrCyan}AZTEC_DIR${clrReset}:   ${clrBlue}$(hum "$AZTEC_DIR_B")${clrReset}  (${clrBlue}$AZTEC_DIR${clrReset})"
echo -e "  ${clrCyan}DATA_DIR${clrReset}:    ${clrBlue}$(hum "$DATA_DIR_B")${clrReset}  (${clrBlue}$DATA_DIR${clrReset})"
echo -e "  ${clrCyan}Docker image${clrReset}: ${clrBlue}$(hum "$IMAGE_SIZE_B")${clrReset}  (${clrBlue}${IMAGE_REPO}:${IMAGE_TAG}${clrReset})"
hr

echo -e "${clrBold}Статус${clrReset}:  $($RUNNING && echo -e "${clrGreen}running${clrReset} (running=true, health=${HEALTH})" || echo -e "${clrRed}stopped${clrReset} (running=false, health=n/a)")"
echo -e "${clrBold}Аптайм${clrReset}:  ${clrBlue}${UPTIME}${clrReset}"
echo -e "${clrBold}CPU${clrReset}:     ${clrBlue}${CPU_PCT}${clrReset}"
echo -e "${clrBold}RAM${clrReset}:     ${clrBlue}${MEM_HUM}${clrReset}  ${clrDim}(${MEM_PCT})${clrReset}"
echo -e "${clrBold}Порты${clrReset}:"
for p in "${PORTS[@]}"; do
  printf "  %s -> %b\n" "${clrCyan}${p}${clrReset}" "$(port_state "$p")"
done
hr

echo -e "${clrBold}Toolchain${clrReset}"
hr
print_tool "aztec"        "$("$aztec_bin" --version 2>/dev/null | head -1 || echo "-")" "$aztec_bin" "$(fsize "$aztec_bin")"
print_tool "cast"         "$("$foundry_cast" --version 2>/dev/null | head -1 || echo "-")" "$foundry_cast" "$(fsize "$foundry_cast")"
print_tool "forge"        "$("$foundry_forge" --version 2>/dev/null | head -1 || echo "-")" "$foundry_forge" "$(fsize "$foundry_forge")"
print_tool "docker"       "$(docker --version 2>/dev/null || echo "-")" "$(whichp docker)" "$(fsize docker)"
print_tool "docker compose" "$(docker compose version 2>/dev/null || echo "-")" "/usr/libexec/docker/cli-plugins/docker-compose" "$(fsize docker-compose || echo 0)"
print_tool "jq"           "$(jq --version 2>/dev/null || echo "-")" "$(whichp jq)" "$(fsize jq)"
print_tool "curl"         "$(curl --version 2>/dev/null | head -1 || echo "-")" "$(whichp curl)" "$(fsize curl)"

hr
echo -e "${clrMag}${clrBold}ИТОГО по Aztec${clrReset}"
hr
TOOLS_B=$(( $(fsize "$aztec_bin") + $(fsize "$foundry_cast") + $(fsize "$foundry_forge") + $(fsize docker) + $(fsize docker-compose || echo 0) + $(fsize jq) + $(fsize curl) ))
TOTAL_B=$(( AZTEC_DIR_B + DATA_DIR_B + IMAGE_SIZE_B + TOOLS_B ))
echo -e "${clrCyan}AZTEC_DIR${clrReset}:     ${clrBlue}$(hum "$AZTEC_DIR_B")${clrReset}"
echo -e "${clrCyan}DATA_DIR${clrReset}:      ${clrBlue}$(hum "$DATA_DIR_B")${clrReset}"
echo -e "${clrCyan}Docker image${clrReset}:  ${clrBlue}$(hum "$IMAGE_SIZE_B")${clrReset}"
echo -e "${clrCyan}Toolchain${clrReset}:     ${clrBlue}$(hum "$TOOLS_B")${clrReset}"
hr
echo -e "${clrBold}Общий размер:${clrReset}  ${clrBlue}$(hum "$TOTAL_B")${clrReset}"
hr
