from tornado import websocket, web, ioloop
import argparse
import json
import paho.mqtt.client as mqtt

import camdemo

# TODO: to send token to browser and get back on post

# Message generation
def gen_conn_message(addr, status):
    data = {
        "action": "conn",
        "addr"  : addr,
        "status": status,
        }
    return json.dumps(data)

def gen_topic_message(topic, message=""):
    data = {
        "action" : "topic",
        "topic"  : topic,
        "message": message,
        }
    return json.dumps(data)

# Call back functions def
def on_connect(mqttc, obj, flags, rc):
    print("MQTT: On connect...")
    addr = "%s:%s" % (mqttc._host, mqttc._port)
    for c in cl:
        if c.addr == addr:
            if rc == 0:
                c.write_message(gen_conn_message(addr, "connected"))
            else:
                c.write_message(gen_conn_message(addr, "failed"))

def on_message(mqttc, obj, msg):
    print("MQTT: On message...")
    addr = "%s:%s" % (mqttc._host, mqttc._port)
    payload = json.loads(str(msg.payload))
    print("Received message: topic:%s payload:%s"
        % (str(msg.topic), str(payload)))

    for c in cl:
        if c.addr == addr and c.topic == msg.topic:
            if payload['readings']:
                c.write_message(
                    gen_topic_message(c.topic, message=payload['readings'][0]))

def on_publish(mqttc, obj, mid):
    print("Published: mid:"+str(mid))

def on_subscribe(mqttc, obj, mid, granted_qos):
    print("Subscribed: mid:"+str(mid)+" "+str(granted_qos))

def on_log(mqttc, obj, level, string):
    print(string)

# Initialize MQTT connection
def init_mqtt_conn(c, ip, port, clientid, timeout=60):
    addr = "%s:%s" % (ip, port)
    mqttc = mqtt.Client(client_id=clientid)
    mqttc.on_connect = on_connect
    mqttc.on_message = on_message
    mqttc.on_publish = on_publish
    mqttc.on_subscribe = on_subscribe
    mqttc.on_log = on_log

    c.addr = addr
    c.mqttc = mqttc

    try:
        mqttc.connect(ip, port, timeout)
    except:
        print("Error: Failed to connect with %s with id %s" % (c.addr, clientid))
        c.write_message(gen_conn_message(c.addr, "failed"))
        return

    print("Connecting with %s with id %s" % (c.addr, clientid))

######################################
cl = []


class IndexHandler(web.RequestHandler):
    def get(self):
        self.render("cam.html")


class SocketHandler(websocket.WebSocketHandler):
    def check_origin(self, origin):
        return True

    def open(self):
        if self not in cl:
            self.mqttc = None
            cl.append(self)

    def on_close(self):
        if self in cl:
            if self.mqttc:
                self.mqttc.loop_stop()
            cl.remove(self)


class ConnectionHandler(web.RequestHandler):

    @web.asynchronous
    def get(self, *args):
        self.finish()

    @web.asynchronous
    def post(self):
        addrs = self.get_arguments("addr")
        ports = self.get_arguments("port")
        clientids = self.get_arguments("clientid")
        if not addrs:
            print("Error: no address.")
            self.finish()
            return
        ip = addrs[0]
        port = 1883 if not ports else int(ports[0])
        clientid = "" if not clientids else clientids[0]
        print("Attempt to Connect: %s:%d by %s" % (ip, port, clientid))
        for c in cl:
            c.write_message(gen_conn_message(ip, "connecting"))
            init_mqtt_conn(c, ip, port, clientid)
            c.mqttc.loop_start()
        self.finish()

    @web.asynchronous
    def delete(self):
        print("disconnected")
        for c in cl:
            if c.mqttc:
                c.mqttc.loop_stop()
                c.write_message(gen_conn_message(c.addr, "disconnected"))
        self.finish()


class SubHandler(web.RequestHandler):
    @web.asynchronous
    def get(self, *args):
        self.finish()

    @web.asynchronous
    def post(self):
        args = self.get_arguments("topic")
        print("Subscribe: %s" % args)
        if not args:
            self.finish()
            return
        topic = args[0]
        for c in cl:
            if not c.mqttc:
                continue
            c.mqttc.subscribe(topic)
            c.topic = topic
            c.write_message(gen_topic_message(topic))
        self.finish()


class PubHandler(web.RequestHandler):
    @web.asynchronous
    def get(self, *args):
        self.finish()

    @web.asynchronous
    def post(self):
        topic = self.get_argument("topic")
        message = self.get_argument("message")
        print("Publish: %s %s" % (topic, message))
        if not topic or not message:
            self.finish()
            return
        for c in cl:
            if not c.mqttc:
                continue
            c.mqttc.publish(topic, message)
            c.topic = topic
        self.finish()


app = web.Application([
    (r'/', IndexHandler),
    (r'/ws', SocketHandler),
    (r'/api', ConnectionHandler),
    (r'/sub', SubHandler),
    (r'/pub', PubHandler),
    (r'/static/(.*)', web.StaticFileHandler, {'path': 'static'}),
], autoreload=True)

if __name__ == '__main__':
    desc = "StarlingX Web Demo"
    parser = argparse.ArgumentParser(description=desc, version='%(prog)s 1.0')
    parser.add_argument('--port',
        help="Port Number",
        default=8888, type=int)
    args = parser.parse_args()

    app.listen(args.port)
    ioloop.IOLoop.instance().start()


