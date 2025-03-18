#!/bin/bash

stopped_containers=$(docker ps -aq -f "status=exited")

if [ -z "$stopped_containers" ]; then
  echo "No stopped containers to start."
else
  echo "Starting stopped containers..."
  docker start $stopped_containers
fi

echo "All stopped containers have been started."
