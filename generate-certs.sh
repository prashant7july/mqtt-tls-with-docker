#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}   EMQX SSL Certificate Generator      ${NC}"
echo -e "${YELLOW}========================================${NC}"

mkdir -p certs

echo -e "\n${GREEN}[1/4] Generating CA key and certificate...${NC}"
openssl genrsa -out certs/ca.key 4096 2>/dev/null
openssl req -x509 -new -nodes -key certs/ca.key -sha256 -days 3650 \
  -out certs/ca.crt -subj "/CN=MyCA" 2>/dev/null
echo -e "      ${GREEN}✔ ca.key and ca.crt created${NC}"

echo -e "\n${GREEN}[2/4] Generating server key...${NC}"
openssl genrsa -out certs/server.key 2048 2>/dev/null
echo -e "      ${GREEN}✔ server.key created${NC}"

echo -e "\n${GREEN}[3/4] Generating Certificate Signing Request...${NC}"
openssl req -new -key certs/server.key -out certs/server.csr \
  -subj "/CN=emqx-broker" 2>/dev/null
echo -e "      ${GREEN}✔ server.csr created${NC}"

echo -e "\n${GREEN}[4/4] Signing server certificate with CA...${NC}"
openssl x509 -req -in certs/server.csr -CA certs/ca.crt -CAkey certs/ca.key \
  -CAcreateserial -out certs/server.crt -days 825 -sha256 2>/dev/null
echo -e "      ${GREEN}✔ server.crt created${NC}"

echo -e "\n${YELLOW}----------------------------------------${NC}"
echo -e "${YELLOW} Verifying...${NC}"
echo -e "${YELLOW}----------------------------------------${NC}"
openssl rsa -check -in certs/server.key > /dev/null 2>&1 \
  && echo -e " ${GREEN}✔ server.key  — valid${NC}" \
  || echo -e " ${RED}✘ server.key  — INVALID${NC}"
openssl x509 -in certs/server.crt -noout > /dev/null 2>&1 \
  && echo -e " ${GREEN}✔ server.crt  — valid${NC}" \
  || echo -e " ${RED}✘ server.crt  — INVALID${NC}"
openssl x509 -in certs/ca.crt -noout > /dev/null 2>&1 \
  && echo -e " ${GREEN}✔ ca.crt      — valid${NC}" \
  || echo -e " ${RED}✘ ca.crt      — INVALID${NC}"
openssl verify -CAfile certs/ca.crt certs/server.crt > /dev/null 2>&1 \
  && echo -e " ${GREEN}✔ cert chain  — OK${NC}" \
  || echo -e " ${RED}✘ cert chain  — FAILED${NC}"

echo -e "\n${GREEN}✔ Done! Now run: ./start.sh${NC}\n"
