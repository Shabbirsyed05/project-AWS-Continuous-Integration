#!/bin/bash
set -e

# Stop the running container (if any)

#containerid=`docker ps | awk -F " " '{print $1}' `
#docker rm -f $containerid

# Stop all running Docker containers
docker stop $(docker ps -aq)

# Remove all stopped Docker containers
docker rm $(docker ps -aq)
