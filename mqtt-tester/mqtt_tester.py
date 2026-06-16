import paho.mqtt.client as mqtt
import time
import json
import random
import threading
from datetime import datetime

# BROKER   = "emqx_host"
# Only in case of when network is default and both tester and broker are in same container network. Otherwise, use the actual hostname or IP address of the EMQX broker.
BROKER   = "emqx" 
PORT     = 1883
TOPIC_SUB = "test/#"
TOPICS_PUB = [
    "test/temperature",
    "test/humidity",
    "test/pressure",
    "test/device/status",
]

# ── Helpers ────────────────────────────────────────────────

def ts():
    return datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

def separator():
    print("-" * 45)

# ── Callbacks ──────────────────────────────────────────────

def on_connect(client, userdata, flags, rc):
    codes = {
        0: "✔  Connected successfully",
        1: "✘  Bad protocol version",
        2: "✘  Client ID rejected",
        3: "✘  Broker unavailable",
        4: "✘  Bad credentials",
        5: "✘  Not authorized",
    }
    print(f"\n[CONNECT] {codes.get(rc, f'Unknown rc={rc}')}")
    if rc == 0:
        client.subscribe(TOPIC_SUB, qos=1)
        print(f"[SUBSCRIBE] → {TOPIC_SUB}")
        separator()

def on_disconnect(client, userdata, rc):
    print(f"\n[DISCONNECT] rc={rc} — will retry...")

def on_message(client, userdata, msg):
    try:
        payload = json.loads(msg.payload.decode())
        print(f"\n[RECEIVED] {msg.topic}")
        for k, v in payload.items():
            print(f"           {k}: {v}")
    except Exception:
        print(f"\n[RECEIVED] {msg.topic} → {msg.payload.decode()}")

# ── Publisher loop ─────────────────────────────────────────

def publish_loop(client):
    count = 0
    while True:
        time.sleep(3)
        count += 1
        now = ts()

        payloads = {
            "test/temperature": {
                "device_id": "sensor_01",
                "value": round(random.uniform(20.0, 35.0), 2),
                "unit": "°C",
                "timestamp": now,
                "msg_id": count,
            },
            "test/humidity": {
                "device_id": "sensor_02",
                "value": round(random.uniform(40.0, 80.0), 2),
                "unit": "%",
                "timestamp": now,
                "msg_id": count,
            },
            "test/pressure": {
                "device_id": "sensor_03",
                "value": round(random.uniform(1000.0, 1025.0), 2),
                "unit": "hPa",
                "timestamp": now,
                "msg_id": count,
            },
            "test/device/status": {
                "device_id": f"device_{random.randint(1, 5):03d}",
                "status": random.choice(["online", "idle", "active"]),
                "battery": random.randint(20, 100),
                "uptime_s": count * 3,
                "timestamp": now,
                "msg_id": count,
            },
        }

        topic = random.choice(TOPICS_PUB)
        payload = json.dumps(payloads[topic])
        result = client.publish(topic, payload, qos=1)
        status = "✔" if result.rc == 0 else "✘"
        print(f"\n[PUBLISH {status}] #{count} → {topic}")

# ── Main ───────────────────────────────────────────────────

def main():
    print("=" * 45)
    print("   EMQX Python MQTT Tester")
    print("=" * 45)
    print(f"  Broker  : {BROKER}:{PORT}")
    print(f"  Sub     : {TOPIC_SUB}")
    print(f"  Pub     : every 3s on random topic")
    print("=" * 45)
    print("\n[INIT] Waiting for EMQX to be ready...")
    time.sleep(5)

    client = mqtt.Client(client_id="python-mqtt-tester", clean_session=True)
    client.on_connect    = on_connect
    client.on_disconnect = on_disconnect
    client.on_message    = on_message

    # Retry until connected
    while True:
        try:
            client.connect(BROKER, PORT, keepalive=60)
            break
        except Exception as e:
            print(f"[RETRY] {e} — retrying in 5s...")
            time.sleep(5)

    # Publisher runs in background thread
    threading.Thread(target=publish_loop, args=(client,), daemon=True).start()

    # Blocking loop
    client.loop_forever()

if __name__ == "__main__":
    main()
