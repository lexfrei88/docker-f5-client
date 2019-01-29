#!/bin/bash

CONTAINER_NAME="f5fpc-vpn"

if [ ! -f ./routes-config.txt ]; then
    echo No routes deleted. 'routes-config.txt' does not exists.
    return 0
fi

readarray -t routes < ./routes-config.txt

echo "Shutting down..."
dockerip=`docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME`
if [ -z $dockerip ]; then
    dockerip='172.17.0.2'
fi
for network in ${routes[@]} ; do
    sudo ip route del $network via $dockerip
done


