VOLUME_PATH	=	./src/.volumes
COMPOSE 	=	docker compose -f ./src/Docker-compose.yml

# Recipe
################################
start:
	$(COMPOSE) up -d

stop:
	$(COMPOSE) down

build:
	$(COMPOSE) build --no-cache

clean:
	$(COMPOSE) down --volumes
	#rm -rf $(VOLUME_PATH)

restart: stop clean build start

show:
	$(COMPOSE) ps

init-prisma:
	cd src/api && npm i prisma @prisma/client && npx prisma init

deinit-prisma:
	cd src/api && npm uninstall prisma @prisma/client


# ===============================================

create_dir:
	mkdir -p $(VOLUME_PATH)/postgres
	mkdir -p $(VOLUME_PATH)/pgadmin

.PHONY: start stop show build clean restart reset create_dir