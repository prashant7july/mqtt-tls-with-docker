#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}        EMQX Quick Start               ${NC}"
echo -e "${YELLOW}========================================${NC}"

# Auto-generate certs if missing
CERTS_OK=true
for f in certs/ca.crt certs/server.crt certs/server.key; do
  [ ! -s "$f" ] && CERTS_OK=false && break
done

if [ "$CERTS_OK" = false ]; then
  echo -e "\n${YELLOW}⚠ Certs missing — generating now...${NC}\n"
  bash generate-certs.sh
else
  echo -e "\n${GREEN}✔ Certificates found${NC}"
fi

echo -e "\n${GREEN}Starting services...${NC}"
docker compose up -d --build

echo -e "\n${YELLOW}----------------------------------------${NC}"
echo -e "${YELLOW} All services started!${NC}"
echo -e "${YELLOW}----------------------------------------${NC}"
echo -e " Dashboard   : ${GREEN}http://localhost:18083${NC}"
echo -e " User        : ${GREEN}admin${NC}  Password: ${GREEN}emqxpass${NC}"
echo -e ""
echo -e " MQTT        : ${GREEN}mqtt://localhost:1883${NC}"
echo -e " MQTT TLS    : ${GREEN}mqtts://localhost:8883${NC}"
echo -e " WS          : ${GREEN}ws://localhost:8083/mqtt${NC}"
echo -e " WSS         : ${GREEN}wss://localhost:8084/mqtt${NC}"
echo -e ""
echo -e " Live logs   : ${GREEN}docker logs -f mqtt-tester${NC}"
echo -e "${YELLOW}----------------------------------------${NC}\n"
