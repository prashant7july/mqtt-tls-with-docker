FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir paho-mqtt==1.6.1

COPY mqtt_tester.py .

CMD ["python", "-u", "mqtt_tester.py"]
