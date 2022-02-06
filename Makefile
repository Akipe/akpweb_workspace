WHAT_OPERATING_SYSTEM 	:= $(shell uname -s)
COMMAND 				:= bash

.PHONY: build run stop clean shell docker-build docker-run docker-stop docker-pull help
.DEFAULT_GOAL= helpmake build

init: git-submodules-fetch-current build containers-create-mount-directories

build: docker-start containers-pull containers-build ## Prepare and start development environment and install php libraries

start: docker-start containers-start ## Start development environment

stop: containers-stop docker-stop ## Stop development environment

update: containers-pull containers-restart

clean: clean-containers-cache

clean-containers-cache:
	rm -R \
		./docker/var/cache/composer/* \
		./docker/var/cache/composer/.* \
		./docker/var/cache/symfony/* \
		./docker/var/cache/symfony/.*

shell: shell-php_cli ## Execute command from PHP container with

shell-nginx:
	docker exec --interactive --tty --user 1000:1000 akpweb_nginx_dev $(COMMAND)

shell-php_cli:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev $(COMMAND)

shell-php_fpm:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_fpm_dev $(COMMAND)

shell-nodejs_tool:
	docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev $(COMMAND)

docker-start: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	systemctl start docker.service
endif

docker-stop: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	systemctl stop docker.service
endif

containers-start:
	docker-compose --file ./docker/docker-compose.yml up --detach

containers-stop:
	docker-compose --file ./docker/docker-compose.yml down

containers-build:
	docker-compose --file ./docker/docker-compose.yml build

containers-pull:
	docker-compose --file ./docker/docker-compose.yml pull

containers-restart: containers-stop containers-start

composer-install:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev composer install

composer-update:
	docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev composer update

containers-create-mount-directories:
	mkdir -p \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/var/cache/symfony
	chmod 777 \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/var/cache/symfony

git-submodules-fetch-current:
	git submodule update --init --recursive

git-submodules-update:
	git submodule update --recursive --remote

dependencies-install-archlinux:
	pacman --needed -Sy \
		docker \
		docker-compose

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)