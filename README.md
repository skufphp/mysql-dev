# MySQL Dev Environment

Локальное окружение для работы с MySQL и phpMyAdmin в Docker. Проект предназначен для централизованного управления базами данных для нескольких локальных проектов.

## 🚀 Быстрый старт

1. **Настройте переменные окружения:**
   ```bash
   cp .env.example .env
   ```
   Отредактируйте `.env` при необходимости (пароли, порты).

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
Для подключения к основной БД, созданной при старте:

* **Host:** `localhost`
* **Port:** `7033` (или ваш `MYSQL_PORT` из `.env`)
* **User:** `root`
* **Password:** `root_password` (или ваш `MYSQL_ROOT_PASSWORD`)

### Через phpMyAdmin
Веб-интерфейс доступен по адресу: [http://localhost:7034](http://localhost:7034) (порт `PHPMYADMIN_PORT` в `.env`).

**Данные для входа в phpMyAdmin:**
* **Username:** `root`
* **Password:** Ваш `MYSQL_ROOT_PASSWORD` (по умолчанию `root_password`)
* **Server:** `mysql-dev` (уже настроено в `docker-compose.yml`)

## 📂 Создание баз “под проекты” (1 MySQL на VPS/сервер, но отдельная БД на каждый проект)

Идея простая и надёжная:

- **MySQL-сервер один** (не плодим контейнеры/сервисы).
- **Каждый проект живёт в своей отдельной базе**.
- **У каждого проекта свой пользователь** (логин/пароль).
- Проекты изолированы: миграции/ошибки/удаления не задевают соседей.

---

## ✅ Что важно понимать заранее

### 1) Laravel **не создаёт базы данных**
Команда `php artisan migrate` создаёт **таблицы** (например, `migrations`, `users`, `jobs`), но **не** делает `CREATE DATABASE`.

Поэтому базу для проекта нужно создать заранее (вручную SQL или через админку).

---

### 🧱 Шаблон: “1 проект = 1 база + 1 пользователь”

Пример для проекта `app1`:

- база: `app1_db`
- пользователь: `app1_user`
- пароль: `<PASSWORD_PLACEHOLDER>`

#### Вариант A — через SQL (рекомендуется)

#### 0) Подключитесь суперпользователем
Подключитесь к MySQL под админом (обычно `root`) через mysql-cli/phpMyAdmin/DataGrip.

#### 1) Создайте пользователя проекта
```sql
CREATE USER 'app1_user'@'%' IDENTIFIED BY '<PASSWORD_PLACEHOLDER>';
```

#### 2) Создайте базу проекта
```sql
CREATE DATABASE app1_db;
```

#### 3) Назначьте права пользователю на базу
```sql
GRANT ALL PRIVILEGES ON `app1_db`.* TO 'app1_user'@'%';
FLUSH PRIVILEGES;
```

Готово: у проекта есть своя база и пользователь, который может в ней работать.

---

### 🔌 Подключение Laravel-проекта к новой базе

В `.env` проекта выставьте:

```dotenv
DB_CONNECTION=mysql
DB_HOST=mysql-dev
DB_PORT=3306
DB_DATABASE=app1_db
DB_USERNAME=app1_user
DB_PASSWORD=<PASSWORD_PLACEHOLDER>
```

После изменения `.env` обязательно сбросьте кэш конфигурации (Laravel это любит):

```bash
docker exec laravel-php-service php artisan config:clear
docker exec laravel-php-service php artisan cache:clear
```

Дальше запускайте миграции:

```bash
php artisan migrate
```

---

### 🔎 Проверка, что таблицы реально создались (SQL)
Подключитесь к **`app1_db`** и выполните:

```sql
SHOW TABLES;
```

Вы должны увидеть как минимум: `migrations`, `users`, `jobs` и т.п. (зависит от набора миграций).

---

### 🧹 Удаление учебного проекта (когда больше не нужен)

> Внимание: удаление необратимо.

```sql
DROP DATABASE app1_db;
DROP USER 'app1_user'@'%';
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
* `make up` — запустить контейнеры.
* `make down` — остановить контейнеры.
* `make restart` — перезапустить контейнеры.
* `make status` — проверить состояние контейнеров.
* `make logs` — просмотр логов всех сервисов.
* `make logs-db` — логи MySQL.
* `make logs-pma` — логи phpMyAdmin.
* `make shell` — зайти в mysql внутри контейнера.
* `make clean` — остановить контейнеры и удалить тома (удалит все данные БД).
* `make clean-all` — полная очистка (контейнеры, тома, образы).