from tornado import websocket, web, ioloop
import json

camcl = []

def gen_camconn_message(addr):
    data = {
        "action": "conn",
        "addr"  : addr
        }
    return json.dumps(data)

class CamHandler(web.RequestHandler):
    def get(self):
        self.render("cam.html")


class CamSocketHandler(websocket.WebSocketHandler):
    def check_origin(self, origin):
        return True

    def open(self):
        if self not in camcl:
            camcl.append(self)

    def on_close(self):
        if self in camcl:
            camcl.remove(self)

class CamConnHandler(web.RequestHandler):
    @web.asynchronous
    def get(self, *args):
        self.finish()

    @web.asynchronous
    def post(self):
        args = self.get_arguments("addr")
        if not args:
            print("No args.")
            return
        print("Connecting to %s" % args[0])
        for c in camcl:
            c.addr = args[0]
            c.write_message(gen_camconn_message(c.addr))

    @web.asynchronous
    def delete(self):
        for c in camcl:
            c.addr = ""
            c.write_message(gen_camconn_message(c.addr))
