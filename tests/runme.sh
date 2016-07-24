#!/usr/bin/env bash

set -x

HOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' consultest)
OUTPUT=$(curl --write-out "%{http_code}\\n" --silent --output /dev/null http://${HOST}:8500/ui/)

if [[ ! $OUTPUT -eq 200 ]]
    then
        echo "Is not OK"
        docker kill consultest
        docker rm consultest
        exit 2
    else
        echo "Is OK"
        docker kill consultest
        docker rm consultest
fi