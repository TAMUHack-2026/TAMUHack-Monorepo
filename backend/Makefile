.PHONY: all postgres gateway model build clean stop 

all: build
	docker compose up -d --remove-orphans

postgres: build
	docker compose up -d postgres

gateway: build
	docker compose up -d gateway

model: build
	docker compose up -d model

build:
	docker compose build

clean: stop

stop:
	docker compose down
