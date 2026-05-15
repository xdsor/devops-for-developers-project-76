### Hexlet tests and linter status:
[![Actions Status](https://github.com/xdsor/devops-for-developers-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/xdsor/devops-for-developers-project-76/actions)

# Redmine Ansible Deploy

Набор Ansible playbook'ов для деплоя Redmine и настройки мониторинга Datadog.  
URL для проверки приложения: https://na15min.ru.   
Для запуска нужно создать .vault_pass в корне проекта с паролем от vault

## Архитектура

Основной сценарий разворачивает Redmine на группе серверов `webservers`.
Внешний балансировщик по заданию предполагается облачным и не настраивается в `playbook.yml`.

В этом репозитории также есть дополнительный VPS-сценарий, где gateway/load balancer поднят самостоятельно:

```text
gateway + load balancer -> Redmine instances
```

Gateway принимает внешний трафик и балансирует его между инстансами Redmine. Связь между хостами в расширенном VPS-сценарии организована через приватную сеть WireGuard.

## Что происходит

Основной плейбук `playbook.yml`:

1. Подготавливает серверы из группы `webservers`: устанавливает pip, Docker и Python-пакет `docker`.
2. Разворачивает Redmine в Docker-контейнере.
3. Настраивает мониторинг с помощью Datadog Agent.

Дополнительные плейбуки `setup_vpn.yml` и `setup_gateway.yml` нужны только для VPS-варианта без облачного load balancer.

## Подготовка

Установите Ansible Galaxy зависимости:

```sh
make install
```

Создайте inventory с группой `webservers`. Пример:

```ini
[webservers]
web1 ansible_host=1.2.3.4 ansible_user=root
web2 ansible_host=1.2.3.5 ansible_user=root
```

Переменные проекта находятся в директории `group_vars/`. Секреты должны храниться в vault-файлах:

```text
group_vars/all/vault.yml
group_vars/webservers/vault.yml
```

Минимально нужны секретные значения:

```yml
svcacc_password: password
redmine_db_password: password
redmine_secret_key_base: secret
datadog_api_key: api-key
```

Для локального запуска с Ansible Vault создайте файл `.vault_pass` в корне проекта.

## Основной деплой

```sh
make deploy
```

Или напрямую:

```sh
ansible-playbook playbook.yml
```

## Команды для разработки

```sh
make install       # Установить Ansible Galaxy роли и коллекции
make syntax        # Проверить синтаксис playbook'ов
make lint          # Запустить ansible-lint
make check         # Запустить syntax + lint
make commit-check  # Запустить check и проверить, что vault-файлы зашифрованы
```

## Дополнительный VPS-деплой

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
