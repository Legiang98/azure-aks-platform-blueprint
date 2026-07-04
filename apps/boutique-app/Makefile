# Makefile for Microservices Demo - Local Build Only

DOCKER_COMPOSE = docker compose

.PHONY: all
all: build

.PHONY: build
build:
	$(DOCKER_COMPOSE) build

.PHONY: clean
clean:
	$(DOCKER_COMPOSE) down --rmi local
