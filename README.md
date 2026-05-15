### Hexlet tests and linter status:
[![Actions Status](https://github.com/xdsor/devops-for-developers-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/xdsor/devops-for-developers-project-76/actions)

# Redmine Ansible Deploy

Набор Ansible playbook'ов для деплоя Redmine.
URL для проверки приложения: https://na15min.ru

## Архитектура

Проект разворачивает Redmine за gateway/load balancer:

```text
gateway + load balancer -> Redmine instances
```

Gateway принимает внешний трафик и балансирует его между инстансами Redmine. Связь между хостами организована через приватную сеть WireGuard.

## Что происходит

1. Подготавливаются серверы: устанавливается Docker, создается системный аккаунт.
2. Подготавливается приватная сеть между хостами с помощью WireGuard.
3. Устанавливается gateway/load balancer на Caddy.
4. Устанавливаются инстансы Redmine.
5. Настраивается мониторинг с помощью Datadog.

## Команды для разработки

```sh
make install       # Установить Ansible Galaxy роли и коллекции
make syntax        # Проверить синтаксис playbook'ов
make lint          # Запустить ansible-lint
make check         # Запустить syntax + lint
make commit-check  # Запустить check и проверить, что vault-файлы зашифрованы
```

## Команды для деплоя

```sh
make initial-setup   # Подготовить серверы: Docker и системный аккаунт
make setup-vpn       # Настроить WireGuard VPN
make setup-gateway   # Настроить gateway/load balancer на Caddy
make setup-redmine   # Развернуть Redmine
make setup-datadog   # Настроить мониторинг Datadog
make setup           # Выполнить полный деплой
```

## Работа с vault

```sh
make vault-encrypt          # Зашифровать vault-файлы
make vault-decrypt          # Расшифровать vault-файлы
make ensure-vault-encrypted # Проверить, что vault-файлы зашифрованы
```
