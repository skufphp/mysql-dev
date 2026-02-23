# MySQL Dev Environment

Локальное окружение для работы с MySQL и phpMyAdmin в Docker. Проект предназначен для централизованного управления базами данных для нескольких локальных проектов.

## 🚀 Быстрый старт

1. **Настройте переменные окружения:**
   ```bash
   cp .env.example .env
   ```
   Отредактируйте `.env` при необходимости (пароли, порты). По умолчанию установлены порты: MySQL — `7033`, phpMyAdmin — `7034`.

2. **Запустите контейнеры:**
   ```bash
   make up
   ```
   Или через Docker Compose:
   ```bash
   docker compose up -d
   ```

3. **Проверьте статус:**
   ```bash
   make status
   ```

## 🔌 Подключение к базам

### Из IDE (PhpStorm / GoLand / DataGrip)
Для подключения к MySQL:

* **Host:** `localhost`
* **Port:** `7033` (или ваш `MYSQL_PORT` из `.env`)
* **User:** `root`
* **Password:** `root` (или ваш `MYSQL_ROOT_PASSWORD`)

### Через phpMyAdmin
Веб-интерфейс доступен по адресу: [http://localhost:7034](http://localhost:7034) (порт `PHPMYADMIN_PORT` в `.env`).

**Данные для входа:**
* **Username:** `root`
* **Password:** Ваш `MYSQL_ROOT_PASSWORD` (по умолчанию `root`)
* **Server:** `mysql-dev` (уже настроено)

## 📂 Создание баз "под проекты"

Чтобы не захламлять `docker-compose.yml` новыми сервисами, создавайте базы и пользователей вручную через phpMyAdmin или консоль:

1. **Зайдите под пользователем root**.
2. **Создайте БД:** например, `app1_db`.
3. **Создайте пользователя:** например, `app1_user` с доступом к этой БД.

Пример SQL для создания пользователя:
```sql
CREATE USER 'app1_user'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON `app1_db`.* TO 'app1_user'@'%';
FLUSH PRIVILEGES;
```

## ⚠️ Важно: Первый старт и Volume

Переменная `MYSQL_ROOT_PASSWORD` используется **только при первой инициализации** пустого хранилища (volume).

* Если вы уже запускали контейнер, а затем поменяли пароль в `.env`, в базе он **не изменится**.
* Чтобы начать с "чистого листа" и применить новые настройки из `.env`, нужно удалить volume:
  ```bash
  make clean
  ```
  **Внимание:** Это действие удалит все созданные вами базы данных и данные в них!

## 🛠 Команды Makefile

* `make help` — показать список доступных команд.
* `make up` — запустить контейнеры (проверяет наличие `.env`).
* `make down` — остановить и удалить контейнеры (данные в volume сохранятся).
* `make restart` — перезапустить контейнеры.
* `make status` — показать статус контейнеров.
* `make logs` — показать логи всех сервисов (follow).
* `make logs-db` — показать логи MySQL (follow).
* `make logs-pma` — показать логи phpMyAdmin (follow).
* `make shell` — открыть консоль MySQL внутри контейнера (`root`).
* `make clean` — остановить контейнеры и удалить volumes (**удалит все данные БД**).
* `make clean-all` — полная очистка: контейнеры + volumes + образы (`--rmi all`).