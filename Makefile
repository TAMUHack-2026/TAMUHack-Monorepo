.PHONY: all build clean stop 

all: build
docker compose up -d --remove-orphans

build:
docker compose build

clean: stop

stop:
docker compose down