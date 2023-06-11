#!/bin/sh

TAG="${1:-latest}"
OPTS="${2:-}"

TIMEZONE="Aisa/Shanghai"

# build [--no-cache]
docker build $OPTS --build-arg timezone=$TIMEZONE -t wdmsyf/alpine-nginx-php:$TAG .

echo "\n-> Build success\n"


