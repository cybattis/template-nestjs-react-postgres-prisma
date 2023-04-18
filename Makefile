NAME		=	webapp-template

VOLUME_PATH	=
COMPOSE 	=	docker compose -f ./src/Docker-compose.yml

API			=	$(NAME)-api
CLIENT		=	$(NAME)-client
POSTGRES	=	$(NAME)-postgres

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
$(eval db:;@:)

$(eval install:;@:)
$(eval delete:;@:)
$(eval generate:;@:)
$(eval migrate:;@:)
$(eval deploy:;@:)

.PHONY: _prisma
_prisma:
ifeq (install, $(filter install,$(MAKECMDGOALS)))
	cd src/api && npm i prisma @prisma/client && npx prisma init
else ifeq (delete, $(filter delete,$(MAKECMDGOALS)))
	cd src/api && npm uninstall prisma @prisma/client
else ifeq (generate, $(filter generate,$(MAKECMDGOALS)))
	docker exec $(API) npx prisma generate
else ifeq (migrate, $(filter migrate,$(MAKECMDGOALS)))
	docker exec $(API) npx prisma migrate dev
else ifeq (deploy, $(filter deploy,$(MAKECMDGOALS)))
	docker exec $(API) npx prisma migrate deploy
endif

BUILD	=	$(COMPOSE) build --no-cache
.PHONY: _build
_build:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'building client'
	$(BUILD) $(CLIENT)
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'building api'
	$(BUILD) $(API)
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'building postgres'
	$(BUILD) $(POSTGRES)
else
	@echo 'building all'
	$(BUILD)
endif

START	=	$(COMPOSE) up -d
.PHONY: _start
_start:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'starting client'
	$(START) $(CLIENT)
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'starting api'
	$(START) $(API)
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'starting postgres'
	$(START) $(POSTGRES) pgadmin
else
	@echo 'starting all'
	$(START)
endif

STOP	=	$(COMPOSE) stop
.PHONY: _stop
_stop:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'stop client'
	$(STOP) $(CLIENT)
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'stop api'
	$(STOP) $(API)
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'stop postgres'
	$(STOP) $(POSTGRES)
else
	@echo 'stop all'
	$(STOP)

endif

CLEAN	=	docker rmi -f
.PHONY: _clean
_clean:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'removing client image'
	$(CLEAN) $(CLIENT)
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'removing api image'
	$(CLEAN) $(API)
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'removing postgres image'
	$(CLEAN) $(POSTGRES)
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
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'Restarting postgres'
	sleep 1
	$(MAKE) prisma deploy
else
	@echo 'Restarting all'
endif

.PHONY: _log
LOG	=	docker logs -f
_log:
ifeq (client, $(filter client,$(MAKECMDGOALS)))
	@echo 'Logging client'
	$(LOG) $(CLIENT)
else ifeq (api, $(filter api,$(MAKECMDGOALS)))
	@echo 'Logging api'
	$(LOG) $(API)
else ifeq (db, $(filter db,$(MAKECMDGOALS)))
	@echo 'Logging postgres'
	$(LOG) $(POSTGRES)
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