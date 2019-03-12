import fcntl, os
from time import sleep
from flask import Flask, render_template, Response

app = Flask(__name__)

@app.route('/')
def index():
    return Response(gen(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

def gen():
    f = open(".lock", "w")
#    print("open .lock")
    while True:
#        print("lock ...")
        fcntl.lockf(f, fcntl.LOCK_EX)
        out = open("out.jpg", "r")
        if out:
            frame = out.read()
        else:
            frame = None
#        print("unlock ...")
        fcntl.lockf(f, fcntl.LOCK_UN)
        if frame:
            yield (b'--frame\r\n' 
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
            sleep(0.1)
         
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=49990, debug=True) 

