#!/bin/bash
echo "Stopping all services..."
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker volume rm $(docker volume ls -q)
docker rmi $(docker images -qa)
docker compose down
echo "✔ Done"
