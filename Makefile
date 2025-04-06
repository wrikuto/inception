NAME			:= inception
DOCKER_COMPOSE	:= docker-compose -f srcs/docker-compose.yml

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

all: build

build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

clean:
	$(DOCKER_COMPOSE) down --volumes

fclean: clean
	docker system prune -af
	docker volume prune -f
	docker network prune -f

re: fclean all

.PHONY: all build up down clean fclean re
