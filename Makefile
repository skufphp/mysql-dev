# ==========================================
# MySQL & phpMyAdmin Docker Environment
# ==========================================

.PHONY: help up down restart logs logs-db logs-pma status shell clean clean-all check-env

# Цвета для вывода
YELLOW=\033[0;33m
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m

# Команда Compose
COMPOSE = docker compose

help: ## Показать справку
	@echo "$(YELLOW)MySQL Dev Environment$(NC)"
	@echo "======================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

check-env: ## Проверить наличие .env файла
	@if [ ! -f .env ]; then \
		echo "$(RED)✗ .env не найден. Скопируйте его из .env.example: cp .env.example .env$(NC)"; \
		exit 1; \
	fi

up: check-env ## Запустить контейнеры
	$(COMPOSE) up -d
	@echo "$(GREEN)✓ Проект запущен$(NC)"
	@echo "$(YELLOW)MySQL доступен на порту:$(NC) $$(grep MYSQL_PORT .env | head -n 1 | cut -d '=' -f 2)"
	@echo "$(YELLOW)phpMyAdmin доступен на:$(NC) http://localhost:$$(grep PHPMYADMIN_PORT .env | cut -d '=' -f 2)"

down: ## Остановить контейнеры
	$(COMPOSE) down

restart: ## Перезапустить контейнеры
	$(COMPOSE) restart

logs: ## Показать логи всех сервисов
	$(COMPOSE) logs -f

logs-db: ## Показать логи MySQL
	$(COMPOSE) logs -f mysql-dev

logs-pma: ## Показать логи phpMyAdmin
	$(COMPOSE) logs -f phpmyadmin-dev

status: ## Статус контейнеров
	$(COMPOSE) ps

shell: ## Войти в консоль mysql внутри контейнера
	$(COMPOSE) exec -it mysql-dev mysql -uroot -p$$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f 2)

clean: ## Остановить контейнеры и удалить тома (ОСТОРОЖНО: удалит все данные БД)
	$(COMPOSE) down -v
	@echo "$(RED)! Контейнеры и данные БД удалены$(NC)"

clean-all: ## Полная очистка (контейнеры, образы, тома)
	$(COMPOSE) down -v --rmi all
	@echo "$(GREEN)✓ Выполнена полная очистка$(NC)"

.DEFAULT_GOAL := help
