# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : server.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-01-11 21:55:27>
##-------------------------------------------------------------------
import os
from flask import Flask, request, make_response
from flask import render_template
from flask import url_for, redirect, send_file

import util
from jinja_html import generate_html

import config

import sys
default_encoding = 'utf-8'
if sys.getdefaultencoding() != default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)

app = Flask(__name__)

################# public backend api ###########################
## sample: http://127.0.0.1:9081/show_post?id=0fa410a29c294cf498c768b0cebc99c0
@app.route("/show_post", methods=['GET'])
def show_post():
    id = request.args.get('id')
    url = "http://{0}:{1}/api_get_post?id={2}".format(config.WEBSERVER_HOST, config.WEBSERVER_PORT, id)
    date = "2013-02-18" # TODO
    filepath = "%s/%s.html" % (util.get_html_dir(), id)
    # TODO: improve time performance to cache
    generate_html(url, filepath, [date])

    # last_modification = '%d' % os.path.getmtime(filepath)
    # return redirect(url_for('static', filename="%s.html" % (id)) + '?' + last_modification)
    return redirect(url_for('get_file', filename="%s.html" % (id)))

@app.route("/show_user_topic", methods=['GET'])
def show_user_topic():
    content = ""
    resp = make_response(content, 200)
    resp.headers['Content-type'] = 'application/json; charset=utf-8'
    return resp

@app.route("/get_file",methods=['GET'])
def get_file():
    filename = request.args.get('filename')
    return send_file("%s/%s" %(util.get_html_dir(), filename))

# static files: TODO better way
@app.route("/resource/<filename>",methods=['GET'])
def get_resource_file(filename):
    return redirect(url_for('get_file', filename="/resource/"+filename))

@app.route("/css-sprite.png",methods=['GET'])
def get_resource_file2():
    return redirect(url_for('get_file', filename="/resource/css-sprite.png"))

@app.route("/favicon.ico",methods=['GET'])
def get_resource_file3():
    return redirect(url_for('get_file', filename="/resource/favicon.ico"))
### TODO better way

## bypass cross domain security
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*') # TODO: to be more secured
    response.headers.add('Access-Control-Allow-Methods', 'GET')
    response.headers.add('Access-Control-Allow-Headers', 'X-Requested-With')
    return response

################################################################

if __name__ == "__main__":
    app.debug = True
    app.run(host="0.0.0.0", port = int(config.FLASK_SERVER_PORT))
## File : server.py
