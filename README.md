Aztec Node Installer (RU/EN) — Docker-based
 _   _           _  _____      
| \ | |         | ||____ |     
|  \| | ___   __| |    / /_ __ 
| . ` |/ _ \ / _` |    \ \ '__|
| |\  | (_) | (_| |.___/ / |   
\_| \_/\___/ \__,_|\____/|_|
          Aztec
     Канал: @NodesN3R


Bilingual, interactive Bash installer/manager for running an Aztec Node via Docker on Debian/Ubuntu.
Версия скрипта / Script version: 1.4.0

English
What this is

A single Bash script that:

Installs prerequisites (APT deps, Docker, Docker Compose plugin) and configures UFW (opens 22/tcp, 40400/tcp+udp, 8080).

Creates ~/aztec, interactively builds a .env, and writes a ready-to-run docker-compose.yml.

Starts the Aztec node, tails logs, checks sync status and RPC health.

Updates the Aztec image tag in compose on demand.

Removes everything cleanly (containers, images, on-host data) with optional .env backup.

Works in English and Russian, with colored output.

Default image tag written to compose: aztecprotocol/aztec:1.2.1 (you can change it via the menu).

Requirements

Ubuntu/Debian with apt.

Root or sudo privileges.

Open network ports: 40400/tcp, 40400/udp, 8080 (UFW rules are applied by the script).

Your own RPC endpoints:

ETHEREUM_RPC_URL — Sepolia RPC HTTP(S) URL.

CONSENSUS_BEACON_URL — Consensus Beacon RPC HTTP(S) URL.

Quick start

Run with Bash, not sh, to ensure colors and prompts render correctly.

# 1) Download the script (adjust <user>/<repo> if needed)
curl -fsSL https://raw.githubusercontent.com/ksydoruk1508/aztec/main/aztec.sh -o aztec.sh

# 2) Make it executable
chmod +x aztec.sh

# 3) Run it (either as root, or with sudo available)
bash ./aztec.sh


You’ll see a menu:

One-click setup (update packages, deps, Docker & UFW)

Create ./aztec, fill .env, and write docker-compose.yml

Start node (docker compose up -d)

Follow logs

Sync status check (Cerberus-Node script)

Check your RPC health

Remove node, images & data (FULL)

Update node version (edit image tag)

Show node version (from compose)

Change language / Сменить язык

Exit

.env variables (asked interactively)

ETHEREUM_RPC_URL — Sepolia RPC endpoint.

CONSENSUS_BEACON_URL — Beacon RPC endpoint.

VALIDATOR_PRIVATE_KEYS — 0x-prefixed private key (keep safe!).

COINBASE — your L1 address (0x...).

P2P_IP — your public IP (auto-detected if blank).

Security: never commit .env to version control. Consider restricting permissions:

chmod 600 ~/aztec/.env

Data & files layout

Working dir: ~/aztec

Compose: ~/aztec/docker-compose.yml

Env: ~/aztec/.env

On-host data (volume): /root/.aztec/alpha-testnet/data/

Common tasks

Start the node

Menu → 3) Start node, or:

cd ~/aztec
docker compose up -d


View logs

Menu → 4) Follow logs, or:

cd ~/aztec
docker compose logs -fn 1000


Update Aztec image version

Menu → 8) Update node version (edit image tag) → enter e.g. 1.2.1.

Show current version (from compose)

Menu → 9) Show node version (from compose).

RPC health

Menu → 6) Check your RPC health (runs a community health check script).

Sync status

Menu → 5) Sync status check (Cerberus-Node community script).

Full removal (containers, images, data)

Menu → 7) Remove node, images & data (FULL).
You’ll be prompted to back up ~/aztec/.env as ~/aztec.env.<timestamp>.bak.

Troubleshooting

Colors printed like \e[0;34m instead of coloring → Run with bash (bash ./aztec.sh).

Docker missing → Run menu item 1) One-click setup.

Locked out by UFW → Script allows 22/tcp and SSH; verify sudo ufw status.

Rate-limited public RPC → Use a dedicated provider endpoint.

Credits

Sync status: Cerberus-Node community script.

RPC Health Check: DeepPatel2412.

Русский

Что это

Интерактивный Bash-скрипт, который:

Ставит зависимости (APT-пакеты, Docker, Docker Compose плагин) и настраивает UFW (открывает 22/tcp, 40400/tcp+udp, 8080).

Создаёт ~/aztec, интерактивно собирает .env и генерирует готовый docker-compose.yml.

Запускает ноду, показывает логи, проверяет синхронизацию и состояние RPC.

Обновляет тег образа Aztec в compose по запросу.

Полностью удаляет всё (контейнеры, образы, данные), предлагает сохранить .env.

Работает на русском и английском, с цветным выводом.

Базовый тег образа, записываемый в compose: aztecprotocol/aztec:1.2.1 (его можно сменить через меню).

Требования

Ubuntu/Debian с apt.

Права root или sudo.

Открытые порты: 40400/tcp, 40400/udp, 8080 (правила UFW применяются скриптом).

Ваши RPC-эндпоинты:

ETHEREUM_RPC_URL — HTTP(S) URL Sepolia RPC.

CONSENSUS_BEACON_URL — HTTP(S) URL Beacon RPC.

Быстрый старт

Запускайте bash, а не sh, чтобы корректно работали цвета и подсказки.

# 1) Скачать скрипт (замените <user>/<repo> при необходимости)
curl -fsSL https://raw.githubusercontent.com/ksydoruk1508/aztec/main/aztec.sh -o aztec.sh

# 2) Сделать исполняемым
chmod +x aztec.sh

# 3) Запустить (под root или с установленным sudo)
bash ./aztec.sh


В меню доступны пункты:

Установить за раз: обновление, зависимости, Docker и UFW

Создать ./aztec, заполнить .env и записать docker-compose.yml

Запустить узел (docker compose up -d)

Смотреть логи

Проверить синхронизацию (скрипт Cerberus-Node)

Проверить ваше RPC

Полное удаление: контейнеры, образы и данные

Обновить версию ноды (заменить тег image)

Показать версию ноды (из compose)

Сменить язык / Change language

Выход

Переменные .env (спрашиваются по очереди)

ETHEREUM_RPC_URL — адрес Sepolia RPC.

CONSENSUS_BEACON_URL — адрес Beacon RPC.

VALIDATOR_PRIVATE_KEYS — приватный ключ с префиксом 0x (храните в секрете!).

COINBASE — ваш L1-адрес (0x...).

P2P_IP — ваш публичный IP (авто-детект, если оставить пустым).

Безопасность: не коммитьте .env в репозиторий. Ограничьте права:

chmod 600 ~/aztec/.env

Где лежат файлы и данные

Рабочая папка: ~/aztec

Compose: ~/aztec/docker-compose.yml

Env: ~/aztec/.env

Данные на хосте (volume): /root/.aztec/alpha-testnet/data/

Частые операции

Запуск ноды

Меню → 3) Запустить узел, или:

cd ~/aztec
docker compose up -d


Логи

Меню → 4) Смотреть логи, или:

cd ~/aztec
docker compose logs -fn 1000


Обновление версии образа Aztec

Меню → 8) Обновить версию ноды → введите, например, 1.2.1.

Показ версии (из compose)

Меню → 9) Показать версию ноды.

Проверка RPC

Меню → 6) Проверить ваше RPC (комьюнити-скрипт проверки здоровья RPC).

Проверка синхронизации

Меню → 5) Проверить синхронизацию (скрипт Cerberus-Node).

Полное удаление

Меню → 7) Полное удаление: контейнеры, образы и данные.
Будет предложено сохранить ~/aztec/.env в ~/aztec.env.<timestamp>.bak.

Неполадки

Вместо цвета видите \e[0;34m → запускайте bash (bash ./aztec.sh).

Docker не найден → пункт меню 1) Установить за раз.

UFW перекрыл доступ → скрипт разрешает 22/tcp и SSH; проверьте sudo ufw status.

Публичные RPC лагают/режутся → используйте личные/провайдерские эндпоинты.

Благодарности

Проверка синка: комьюнити-скрипт Cerberus-Node.

RPC Health Check: DeepPatel2412.

Maintainers / Support

Channel: @NodesN3R

Pull requests and issues are welcome.
