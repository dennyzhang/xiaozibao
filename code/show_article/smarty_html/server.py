# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : server.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-01-11 16:30:28>
##-------------------------------------------------------------------
from flask import Flask
from flask import render_template
from flask import make_response
from flask import request

import config
import data

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
    # TODO defensive code
    id = request.args.get('id', '')
    post = data.get_post(id)
    post.content = post.content[0:config.MAX_LENGTH]
    content = render_template('get_post.json', post=post)
    content = smarty_remove_extra_comma(content)
    resp = make_response(content, 200)
    resp.headers['Content-type'] = 'application/json; charset=utf-8'
    return resp

@app.route("/show_user_topic", methods=['GET'])
def show_user_topic():
    # TODO defensive code
    userid = request.args.get('userid', '')
    topic = request.args.get('topic', '')
    start_num = request.args.get('start_num', 0)
    count = request.args.get('count', 10)
    id_list = data.list_user_topic(userid, topic, int(start_num), int(count))
    print id_list
    content = render_template('list_user_topic.json', id_list=id_list)
    resp = make_response(content, 200)
    resp.headers['Content-type'] = 'application/json; charset=utf-8'
    return resp

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
