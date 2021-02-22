WHAT_OPERATING_SYSTEM 	:= $(shell uname -s)
COMMAND 				:= bash

.PHONY: build run stop clean shell docker-build docker-run docker-stop docker-pull help
.DEFAULT_GOAL= helpmake build

dependencies-install-archlinux: 
	sudo pacman --needed -Sy \
		docker \
		docker-compose
	yay -S \
		gitflow-avh

build: system-docker-run docker-pull docker-build docker-run ## Prepare and start development environment and install php libraries

run: system-docker-run docker-run ## Start development environment

stop: docker-stop system-docker-stop ## Stop development environment

init: git-submodules-fetch-current build
	mkdir -p \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/varcache/symfony
	chmod 777 \
		./docker/var/log \
		./docker/var/cache/composer \
		./docker/var/cache/symfony

update: docker-pull docker-restart gpm-update

clean:  ## Clear all caches
	rm -R \
		./docker/var/cache/composer/* \
		./docker/var/cache/composer/.* \
		./docker/var/cache/symfony/* \
		./docker/var/cache/symfony/.*

shell: ## Execute command from PHP container with 
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev $(COMMAND)

shell-nginx:
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_nginx_dev $(COMMAND)

shell-php-fpm:
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_php_fpm_dev $(COMMAND)

shell-nodejs-tool:
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_nodejs_tools_dev $(COMMAND)

system-docker-run: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	sudo systemctl start docker.service
endif

system-docker-stop: ## Execute Docker (Only on Linux)
ifeq ($(WHAT_OPERATING_SYSTEM), Linux)
	sudo systemctl stop docker.service
endif

docker-run:
	sudo docker-compose --file ./docker/docker-compose.yml up --detach

docker-stop:
	sudo docker-compose --file ./docker/docker-compose.yml down

docker-build:
	sudo docker-compose --file ./docker/docker-compose.yml build

docker-pull:
	sudo docker-compose --file ./docker/docker-compose.yml pull

docker-restart: docker-stop docker-run

composer-install:
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev composer install

composer-update:
	sudo docker exec --interactive --tty --user 1000:1000 akpweb_php_cli_dev composer update

git-submodules-fetch-current:
	git submodule update --init --recursive

git-submodules-update:
	git submodule update --recursive --remote

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)