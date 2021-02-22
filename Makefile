WHAT_OPERATING_SYSTEM 	:= $(shell uname -s)
COMMAND 				:= bash

.PHONY: build run stop clean shell docker-build docker-run docker-stop docker-pull help
.DEFAULT_GOAL= helpmake bui

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
	mkdir \
		./docker/_cache/composer \
		./docker/_cache/symfony
	chmod 777 \
		./docker/_cache/composer \
		./docker/_cache/symfony

update: docker-pull docker-restart gpm-update

clean:  ## Clear all caches
	rm -R \
		./docker/_cache/composer/* \
		./docker/_cache/composer/.* \
		./docker/_cache/symfony/.*

shell: ## Execute command from PHP container with 
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev $(COMMAND)


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
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev composer install

composer-update:
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev composer update

gpm:
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev bin/gpm $(COM)

gpm-update:
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev bin/gpm selfupgrade -f

gpm-install:
	sudo docker exec -it --user 1000:1000 akpweb_php-cli_dev bin/gpm install $(WHAT)

git-submodules-fetch-current:
	git submodule update --init --recursive

git-submodules-update:
	git submodule update --recursive --remote

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)