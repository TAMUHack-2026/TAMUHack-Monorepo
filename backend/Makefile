.PHONY: all up postgres usermanagement model services build clean down

all: build up

up: 
	docker compose up -d

postgres: build
	docker compose up -d postgres

usermanagement: build
	docker compose up -d usermanagement

model: build
	docker compose up -d model

services:
	@echo "Available services to start:"
	@echo "make postgres       - Start PostgreSQL service"
	@echo "make usermanagement - Start User Management service"
	@echo "make model          - Start Model service"

build:
	@for file in ../docs/api/*.yaml; do \
		name=$$(basename "$$file" .yaml); \
		mkdir -p "./$$name/src/main/resources/static" > /dev/null 2>&1; \
		cp "$$file" "./$$name/src/main/resources/static/openapi.yaml" > /dev/null 2>&1; \
	done
	docker compose build

clean:
	docker compose down --volumes --rmi all

down:
	docker compose down
