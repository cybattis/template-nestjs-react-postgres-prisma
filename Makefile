NAME		=	webapp-template

VOLUME_PATH	=	./src/.volumes
COMPOSE 	=	docker compose -f ./src/Docker-compose.yml

# Recipe
################################
start: _start

stop: _stop

build: _build

clean: stop _clean

fclean: clean
	$(COMPOSE) down --volumes

restart: _restart clean start

show:
	$(COMPOSE) ps

prisma: _prisma

studio:
	cd src/api && npx prisma studio

log: _log

create_dir:
	mkdir -p $(VOLUME_PATH)/postgres
	mkdir -p $(VOLUME_PATH)/pgadmin

list: help
help: _help

.PHONY: start stop build clean fclean restart show prisma studio log create_dir list help

# ===============================================

# turn them into do-nothing targets
$(eval client:;@:)
$(eval api:;@:)
$(eval postgres:;@:)

.PHONY: _prisma
_prisma:
ifeq (init, $(filter init,$(MAKECMDGOALS)))
	cd src/api && npm i prisma @prisma/client && npx prisma init
else ifeq (delete, $(filter delete,$(MAKECMDGOALS)))
	cd src/api && npm uninstall prisma @prisma/client
else ifeq (generate, $(filter generate,$(MAKECMDGOALS)))
	cd src/api && npx prisma generate
	docker exec api npx prisma generate
else ifeq (migrate, $(filter migrate,$(MAKECMDGOALS)))
	cd src/api && npx prisma migrate dev
endif

BUILD	=	$(COMPOSE) build --no-cache
.PHONY: _build
_build:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'building client'
	$(BUILD) client
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'building api'
	$(BUILD) api
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'building postgres'
	$(BUILD) postgres
else
	@echo 'building all'
	$(BUILD)
endif

START	=	$(COMPOSE) up -d
.PHONY: _start
_start:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'starting client'
	$(START) client
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'starting api'
	$(START) api
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'starting postgres'
	$(START) postgres pgadmin
else
	@echo 'starting all'
	$(START)
endif

STOP	=	$(COMPOSE) stop
.PHONY: _stop
_stop:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'stop client'
	$(STOP) client
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'stop api'
	$(STOP) api
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'stop postgres'
	$(STOP) postgres
else
	@echo 'stop all'
	$(STOP)

endif

CLEAN	=	docker rmi -f
.PHONY: _clean
_clean:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'removing client image'
	$(CLEAN) $(NAME)-client
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'removing api image'
	$(CLEAN) $(NAME)-api
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'removing postgres image'
	$(CLEAN) postgres
else
	@echo 'removing all images'
	$(CLEAN) $(NAME)-client $(NAME)-api postgres
endif

.PHONY: _restart
_restart:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'Restarting client'
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'Restarting api'
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'Restarting postgres'
else
	@echo 'Restarting all'
endif

.PHONY: _log
LOG	=	docker logs -f
_log:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'Logging client'
	$(LOG) client
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'Logging api'
	$(LOG) api
else ifeq (postgres, $(filter postgres,$(MAKECMDGOALS)))
	@echo 'Logging postgres'
	$(LOG) postgres
endif

.PHONY: _help
_help:
	@echo "======================================================"
	@echo "\t\t\tMAKE HELP"
	@echo "======================================================"
	@echo ""
	@echo "Command: start stop build clean fclean restart show "
	@echo "\t prisma studio log"
	@echo ""


# ==============================================================================
#	Extra
# ==============================================================================
_GREY	= \033[30m
_RED	= \033[31m
_ORANGE	= \033[38;5;209m
_GREEN	= \033[32m
_YELLOW	= \033[33m
_BLUE	= \033[34m
_PURPLE	= \033[35m
_CYAN	= \033[36m
_WHITE	= \033[37m
_END	= \033[0m