#!/bin/bash

running_containers=$(docker ps -q)

if [ -z "$running_containers" ]; then
  echo "No running containers to stop."
else
  echo "Stopping running containers"
  docker stop $running_containers
fi

echo "All Running Containers are Stopped"
