#!/bin/bash -e
cd /webroot/webapp/
#HTTP_PORT=8000
# for python 3
#HTTP_SVR_MODULE="http.server"
#for python 2.7
#HTTP_SVR_MODULE="SimpleHTTPServer"
echo "start to run http server"
#python -m $HTTP_SVR_MODULE $HTTP_PORT
python app.py


