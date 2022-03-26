WHAT_OPERATING_SYSTEM 	:= $(shell uname -s)
COMMAND 				:= bash

.PHONY: build run stop clean shell docker-build docker-run docker-stop docker-pull help
.DEFAULT_GOAL= helpmake build


### General commands

init: git-submodules-fetch-current build containers-create-mount-directories

build: docker-start containers-pull containers-build ## Prepare and start development environment and install php libraries

start: docker-start containers-start ## Start development environment

stop: containers-stop docker-stop ## Stop development environment

update: containers-pull containers-build containers-restart

clean: clean-containers-cache

shell: shell-php_cli ## Execute command from PHP container with


### Docker

docker-start: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	systemctl start docker.service
endif

docker-stop: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	systemctl stop docker.service
endif


### Shell

shell-nginx:
	docker exec --interactive --tty --user 1000:1000 akpweb_nginx_dev $(COMMAND)

shell-php_cli:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev $(COMMAND)

shell-php_fpm:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_fpm_dev $(COMMAND)

shell-nodejs_tool:
	docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev $(COMMAND)


### Containers

containers-start:
	docker-compose --file ./docker/docker-compose.yml up --detach

containers-stop:
	docker-compose --file ./docker/docker-compose.yml down

containers-build:
	docker-compose --file ./docker/docker-compose.yml build

containers-pull:
	docker-compose --file ./docker/docker-compose.yml pull

containers-restart: containers-stop containers-start

containers-create-mount-directories:
	mkdir -p \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/var/cache/symfony
	chmod 777 \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/var/cache/symfony


### Clean

clean-containers-cache:
	rm -R \
		./docker/var/cache/composer/* \
		./docker/var/cache/composer/.* \
		./docker/var/cache/symfony/* \
		./docker/var/cache/symfony/.*


### Git

git-submodules-fetch-current:
	git submodule update --init --recursive

git-submodules-update:
	git submodule update --recursive --remote


### Apps commands

composer-install:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		composer install

composer-update:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		composer update

npm-install:
	docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev \
		npm install

npm-update:
	docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev \
		npm update

sf-check-requirements:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		symfony check:requirements

sf-about:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console about

sf-check-security:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
    	symfony check:security

sf-debug-router:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console debug:router

sf-debug-dotenv:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console debug:dotenv

sf-doctrine-database-create:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console doctrine:database:create

sf-doctrine-migration-create:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console make:migration

sf-doctrine-migration-execute:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console doctrine:migrations:migrate

sf-doctrine-migrations-reset:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console doctrine:migrations:migrate first -n

sf-make-entity:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console make:entity

sf-make-entity-regenerate:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console make:entity --regenerate

sf-make-controller:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console make:controller

sf-show-cache:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console cache:pool:list

sf-clear-cache:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev \
		php bin/console cache:pool:clear cache.global_clearer

sf-assets-compile:
	docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev \
		npm run watch

### Commands for preparing host system

dependencies-install-archlinux:
	pacman --needed -Sy \
		docker \
		docker-compose


### Help

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)