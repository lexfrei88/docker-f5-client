#!/bin/bash

trap 'exit' SIGINT SIGTERM

while true ; do
	sleep 5m
    ping -c 1 google.com > /dev/null 2>&1
    if [[ "$?" -ne 0 ]]
        echo Can\'t ping google.com. Closing VPN connection.
        exit
    fi
done
