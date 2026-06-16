# mqtt-tls-with-docker
MQTT TLS with Docker

## ⚡ One command to run everything
```bash 
chmod +x start.sh generate-certs.sh stop.sh
./start.sh
```
- Certs are **auto-generated** if missing
- MQTT tester starts **after EMQX is healthy**

---

## Watch live MQTT data
```bash
docker logs -f mqtt-tester
```

### Sample output
```
=============================================
   EMQX Python MQTT Tester
=============================================
  Broker  : emqx_host:1883
  Sub     : test/#
  Pub     : every 3s on random topic
=============================================

[CONNECT] ✔  Connected successfully
[SUBSCRIBE] → test/#
---------------------------------------------

[PUBLISH ✔] #1 → test/temperature
[RECEIVED] test/temperature
           device_id: sensor_01
           value: 27.43
           unit: °C
           timestamp: 2024-01-15T10:30:00Z
           msg_id: 1

[PUBLISH ✔] #2 → test/device/status
[RECEIVED] test/device/status
           device_id: device_003
           status: active
           battery: 87
           uptime_s: 6
           timestamp: 2024-01-15T10:30:03Z
           msg_id: 2
```

---

## Stop
```bash
./stop.sh
```

---

## Project Structure
```
emqx-project/
├── docker-compose.yml
├── start.sh               ← one-click start
├── stop.sh                ← one-click stop
├── generate-certs.sh      ← auto-called by start.sh
├── README.md
├── certs/                 ← auto-created on first run
│   ├── ca.crt             ← use in MQTTX app
│   ├── server.crt
│   └── server.key
└── mqtt-tester/
    ├── Dockerfile          ← python:3.11-slim + paho-mqtt
    └── mqtt_tester.py      ← pub + sub on test/#
```

---

## MQTT Topics Published (every 3s, random)
| Topic | Fields |
|---|---|
| `test/temperature` | device_id, value (°C), unit, timestamp, msg_id |
| `test/humidity` | device_id, value (%), unit, timestamp, msg_id |
| `test/pressure` | device_id, value (hPa), unit, timestamp, msg_id |
| `test/device/status` | device_id, status, battery, uptime_s, timestamp, msg_id |

---

## MQTTX App — Connect & Test
| Protocol | Host | Port | SSL | CA Cert |
|---|---|---|---|---|
| MQTT | localhost | 1883 | ❌ | — |
| MQTT TLS | localhost | 8883 | ✅ | certs/ca.crt |
| WebSocket | localhost | 8083 | ❌ | — |
| WebSocket TLS | localhost | 8084 | ✅ | certs/ca.crt |

Subscribe to `test/#` to see live data flowing in.

---

## Dashboard
| | |
|---|---|
| URL | http://localhost:18083 |
| User | admin |
| Password | emqxpass |
