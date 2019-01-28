#!/bin/bash

trap 'exit' SIGINT SIGTERM

while true ; do
	sleep 5m
    ping -c 1 google.com
done
