<!--
  Aztec Node Installer — README
  Script version: v1.4.0
-->

<div align="center">

```
 _   _           _  _____      
| \ | |         | ||____ |     
|  \| | ___   __| |    / /_ __ 
| . ` |/ _ \ / _` |    \ \ '__|
| |\  | (_) | (_| |.___/ / |   
\_| \_/\___/ \__,_|\____/|_|
          Aztec
     Канал: @NodesN3R
```

# Aztec Node — Docker Installer (RU/EN)

[![OS Ubuntu](https://img.shields.io/badge/OS-Ubuntu%20%2F%20Debian-E95420)](https://ubuntu.com/)
[![Shell](https://img.shields.io/badge/Shell-bash-4EAA25)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-required-2496ED)](https://www.docker.com/)
[![Compose](https://img.shields.io/badge/Compose-plugin-1D63ED)](https://docs.docker.com/compose/)
[![Arch](https://img.shields.io/badge/Arch-x86__64%20%2F%20arm64-6E56CF)](#)
[![Lang](https://img.shields.io/badge/Lang-RU%20%7C%20EN-10b981)](#)
[![Version](https://img.shields.io/badge/Script-v1.4.0-0ea5e9)](#)
[![License](https://img.shields.io/badge/License-MIT-8b5cf6)](#license)

## Hardware Requirements (Practical)
Get a VPS that meets the minimum specs below, then proceed to the next step.

If you plan to run your own RPC, get a bigger VPS - Check specs first : RPC Setup Guide


**English** • [Русский](#русский)

</div>

---

## English

---

CPU           :   4 Core
RAM           :   8GB
Disk          :   250GB SSD
OS            :   Linux or MacOS
Network   :   25 Mbps up/down

---

### ✨ What it does
Bilingual, interactive **Bash** script that helps you run an **Aztec Node** via **Docker** on Ubuntu/Debian:

- ☑️ One-click system prep: APT packages, **Docker**, **Compose plugin**, **UFW** rules  
- 🧰 Creates `~/aztec`, builds `.env` interactively, writes ready-to-run `docker-compose.yml`  
- ▶️ Starts the node, 📜 tails logs, 🩺 checks sync status & RPC health  
- 🔁 Updates Aztec **image tag** right in compose  
- 🧹 Full cleanup (containers, images, on-host data) with optional `.env` backup  
- 🌍 RU/EN UI with colored output

> Default image tag in compose: `aztecprotocol/aztec:1.2.1` (change via menu when needed)

---

### 🚀 Quick start

> Run with **bash** (not `sh`) to ensure colors and prompts render correctly.

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/ksydoruk1508/aztec/main/aztec.sh -o aztec.sh

# Make executable
chmod +x aztec.sh

# Run
bash ./aztec.sh
```

---

### 🧭 Menu overview

1. **One-click setup** — update packages, install deps, Docker & UFW  
2. **Create `./aztec`** — fill `.env`, write `docker-compose.yml`  
3. **Start node** — `docker compose up -d`  
4. **Follow logs** — live logs with `-fn 1000`  
5. **Sync status** — community script (Cerberus-Node)  
6. **RPC health** — community script (DeepPatel2412)  
7. **Full removal** — containers, images & data; optional `.env` backup  
8. **Update node version** — change image tag in compose and restart  
9. **Show node version** — reads image tag from compose  
10. **Change language** — RU/EN  
11. **Exit**

---

### 🔐 `.env` variables (asked interactively)

| Variable                | Description                                   |
|-------------------------|-----------------------------------------------|
| `ETHEREUM_RPC_URL`      | Sepolia RPC HTTP(S) URL                       |
| `CONSENSUS_BEACON_URL`  | Consensus Beacon RPC HTTP(S) URL              |
| `VALIDATOR_PRIVATE_KEYS`| **0x-prefixed private key** (keep safe!)      |
| `COINBASE`              | Your L1 address (0x…)                         |
| `P2P_IP`                | Your public IP (auto-detected if left blank)  |

> **Security:** never commit `.env`. Consider:  
> `chmod 600 ~/aztec/.env`

---

### 📂 Paths & data

- Work dir: `~/aztec`  
- Compose: `~/aztec/docker-compose.yml`  
- Env: `~/aztec/.env`  
- On-host data (volume): `/root/.aztec/alpha-testnet/data/`

---

### 🔧 Common commands

```bash
# Start manually
cd ~/aztec && docker compose up -d

# Logs
cd ~/aztec && docker compose logs -fn 1000

# Show current image tag (from compose)
# (or use menu option #9)
grep -E 'image:\s*aztecprotocol/aztec:' ~/aztec/docker-compose.yml

# Update node (use menu #8) — enter e.g. 1.2.1 when prompted

# Full removal (use menu #7) — will offer to backup .env
```

---

### 🧯 Troubleshooting

- **Colors show as `\e[0;34m`** → run with **bash**: `bash ./aztec.sh`  
- **Docker missing** → use menu **1** (One-click setup)  
- **UFW blocks SSH** → script allows `22/tcp` and `ssh`; verify `sudo ufw status`  
- **Public RPC issues** → prefer a reliable provider endpoint

---

### 🙏 Credits

- Sync status script — Cerberus-Node community  
- RPC Health Check — DeepPatel2412

---

## Русский

### ✨ Что умеет
Двуязычный интерактивный **Bash-скрипт** для запуска **Aztec-ноды** через **Docker** на Ubuntu/Debian:

- ☑️ Быстрая подготовка: APT-пакеты, **Docker**, **Compose-плагин**, правила **UFW**  
- 🧰 Создаёт `~/aztec`, собирает `.env`, пишет готовый `docker-compose.yml`  
- ▶️ Запускает ноду, 📜 показывает логи, 🩺 проверяет синхронизацию и RPC  
- 🔁 Обновляет **тег образа** Aztec в compose  
- 🧹 Полное удаление (контейнеры, образы, данные) с предложением сохранить `.env`  
- 🌍 Интерфейс RU/EN с цветным выводом

> Базовый тег образа в compose: `aztecprotocol/aztec:1.2.1` (меняется через меню)

---

### 🚀 Быстрый старт

> Запускайте **bash** (не `sh`), чтобы корректно работали цвета и подсказки.

```bash
# Скачать скрипт
curl -fsSL https://raw.githubusercontent.com/ksydoruk1508/aztec/main/aztec.sh -o aztec.sh

# Выдать права на исполнение
chmod +x aztec.sh

# Запустить
bash ./aztec.sh
```

---

### 🧭 Обзор меню

1. **Установить за раз** — обновление, зависимости, Docker и UFW  
2. **Создать `./aztec`** — заполнить `.env`, записать `docker-compose.yml`  
3. **Запустить узел** — `docker compose up -d`  
4. **Смотреть логи** — живые логи с `-fn 1000`  
5. **Проверка синхронизации** — скрипт сообщества (Cerberus-Node)  
6. **Проверка RPC** — скрипт сообщества (DeepPatel2412)  
7. **Полное удаление** — контейнеры, образы и данные; опциональный бэкап `.env`  
8. **Обновить версию ноды** — смена тега образа в compose и перезапуск  
9. **Показать версию ноды** — чтение тега из compose  
10. **Сменить язык** — RU/EN  
11. **Выход**

---

### 🔐 Переменные `.env`

| Переменная               | Назначение                                    |
|--------------------------|-----------------------------------------------|
| `ETHEREUM_RPC_URL`       | HTTP(S) адрес Sepolia RPC                     |
| `CONSENSUS_BEACON_URL`   | HTTP(S) адрес Beacon RPC                      |
| `VALIDATOR_PRIVATE_KEYS` | **Приватный ключ** с префиксом `0x`           |
| `COINBASE`               | Ваш L1-адрес (0x…)                            |
| `P2P_IP`                 | Ваш публичный IP (авто, если оставить пустым) |

> **Безопасность:** не коммитьте `.env`. Рекомендуется:  
> `chmod 600 ~/aztec/.env`

---

### 📂 Пути и данные

- Рабочая папка: `~/aztec`  
- Compose: `~/aztec/docker-compose.yml`  
- Env: `~/aztec/.env`  
- Данные на хосте (volume): `/root/.aztec/alpha-testnet/data/`

---

### 🔧 Частые команды

```bash
# Старт вручную
cd ~/aztec && docker compose up -d

# Логи
cd ~/aztec && docker compose logs -fn 1000

# Текущий тег образа (из compose)
grep -E 'image:\s*aztecprotocol/aztec:' ~/aztec/docker-compose.yml

# Обновление версии ноды — пункт меню №8

# Полное удаление — пункт меню №7 (предложит сохранить .env)
```

---

### 🧯 Решение проблем

- **Вместо цвета видны коды `\e[0;34m`** → запускайте **bash**: `bash ./aztec.sh`  
- **Docker не установлен** → пункт меню **1**  
- **UFW перекрыл SSH** → скрипт разрешает `22/tcp` и `ssh`; проверьте `sudo ufw status`  
- **Публичные RPC нестабильны** → используйте надёжный провайдерский эндпоинт

---

### 🙏 Благодарности

- Проверка синхронизации — скрипт сообщества Cerberus-Node  
- Проверка RPC — скрипт сообщества DeepPatel2412

---

## License

MIT — see `LICENSE`. PRs and issues welcome 👋
