import os
import sys
import json
import time
import subprocess
import paho.mqtt.client as mqtt

def camera_handle(command):
    if command == "camera_on" and not camera_handle.proc:
#        camera_handle.proc = subprocess.Popen(['python3 /opt/edgex-pi-demo/camera2http.py'], shell=True)
        camera_handle.proc = subprocess.Popen(['/usr/local/bin/ffmpeg -f v4l2 -i /dev/video0 http://localhost:49990/camera.ffm'], shell=True)
    elif command == "camera_off" and camera_handle.proc: 
#        os.system("kill `cat /tmp/camera2http.pid`")
        os.system("killall ffmpeg")
        camera_handle.proc.terminate()
        camera_handle.proc.wait()
        camera_handle.proc = None
    else:
        print("invalid command: {0}".format(command))

camera_handle.proc = None

def on_message(client, userdata, message):
    print("message received {0}".format(str(message.payload.decode("utf-8"))))
    msg = json.loads(str(message.payload.decode("utf-8")))
    host = msg.get("host", "localhost")
    port = msg.get("port", "49991")
    device = msg.get("device", "all")
    command = msg.get("command", "set")
    data = json.dumps(msg.get("data", {}))
    if command == "camera_on" or command == "camera_off":
        camera_handle(command)
    else:
        run = 'curl -H "Content-Type: application/json" -d \'{0}\' http://{1}:{2}/api/v1/device/{3}/{4}'.format(data, host, port, device, command)
        print(run)
        os.system(run)

broker_address=os.environ["MQTT_BROKER_ADDR"]
broker_port=int(os.environ.get("MQTT_BROKER_PORT", "1883"))
client = mqtt.Client("EdgeX/Command")
client.on_message = on_message
client.connect(broker_address, broker_port)
print("Subscribing to topic: EdgeX/Command ...")
client.subscribe("EdgeX/Command")
client.loop_forever()
