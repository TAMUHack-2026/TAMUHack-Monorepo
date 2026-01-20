.PHONY: all up postgres gateway usermanagement model services build clean stop 

all: build up

up: 
	docker compose up -d

postgres: build
	docker compose up -d postgres

gateway: build
	docker compose up -d gateway

usermanagement: build
	docker compose up -d usermanagement

model: build
	cp ../docs/api/model.yaml ./model/static/model.yaml
	docker compose up -d model

services:
	@echo "Available services to start:"
	@echo "make postgres       - Start PostgreSQL service"
	@echo "make gateway        - Start API Gateway service"
	@echo "make usermanagement - Start User Management service"
	@echo "make model          - Start Model service"

build:
	for file in ../docs/api/*.yaml; do \
		name=$$(basename "$$file" .yaml); \
		cp "$$file" "./$$name/src/main/resources/static/openapi.yaml" > /dev/null 2>&1; \
	done
	docker compose build

clean:
	docker compose down --volumes --rmi all

down:
	docker compose down
