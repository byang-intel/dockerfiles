#!/usr/bin/env python3

from time import sleep
from flask import Flask, render_template, Response

app = Flask(__name__)

@app.route('/')
def index():
    return Response(gen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

def gen():
    while True:
        out = open("out.jpg", "rb")
        if out:
            frame = out.read()
            out.close()
        else:
            frame = None
        if frame:
            yield (b'--frame\r\n' 
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
         
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=49990, threaded=True, debug=True)
