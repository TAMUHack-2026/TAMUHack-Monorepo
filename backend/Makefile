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
	mkdir -p ./usermanagement/src/main/resources/static
	mkdir -p ./model/static
	cp ../docs/api/usermanagement.yaml ./usermanagement/src/main/resources/static/openapi.yaml
	cp ../docs/api/model.yaml ./model/static/openapi.yaml
	docker compose build

clean:
	docker compose down --volumes --rmi all

down:
	docker compose down
