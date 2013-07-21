# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : server.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-07-21 21:11:58>
##-------------------------------------------------------------------
from flask import Flask
from flask import render_template
from flask import make_response
from flask import request

from util import POST
from util import get_id_by_title
from util import smarty_remove_extra_comma

import config
import data

import sys
default_encoding = 'utf-8'
if sys.getdefaultencoding() != default_encoding:
	reload(sys)
	sys.setdefaultencoding(default_encoding)

app = Flask(__name__)

@app.route("/")
def index():
	return "您持续感兴趣的，就是要采编的!"

################# public backend api ###########################
## sample: http://127.0.0.1:9080/api_get_post?id=0fa410a29c294cf498c768b0cebc99c0
@app.route("/api_get_post", methods=['GET'])
def get_post():
	# TODO defensive code
	id = request.args.get('id', '')
	post = data.get_post(id)
	content = render_template('get_post.json', post=post)
	content = smarty_remove_extra_comma(content)
	resp = make_response(content, 200)
	resp.headers['Content-type'] = 'application/json; charset=utf-8'
	return resp

## sample: http://127.0.0.1:8081/api_list_user_post?userid=denny&date=2013-01-24
## sample: http://127.0.0.1:8081/api_list_user_post?userid=denny
# Note: If date is empty, list all posts deliver to a given user without filtering date
@app.route("/api_list_user_post", methods=['GET'])
def list_user_post():
	# TODO defensive code
	userid = request.args.get('userid', '')
	date = request.args.get('date', '')
	posts = data.list_user_post(userid, date)
	content = render_template('list_user_post.json', posts=posts)
	content = smarty_remove_extra_comma(content)
	resp = make_response(content, 200)
	resp.headers['Content-type'] = 'application/json; charset=utf-8'
	return resp

## http://127.0.0.1:9080/api_list_user_topic?uid=denny&topic=idea_startup&start_num=0&count=10
@app.route("/api_list_user_topic", methods=['GET'])
def list_user_topic():
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

################# private backend api ###########################
# sample: http://127.0.0.1:8081/api_insert_post
# Note: this is an internal api
@app.route("/api_insert_post", methods=['POST'])
def insert_post():
	return "TODO be implemented"
################################################################

if __name__ == "__main__":
	app.debug = True
	app.run(host="0.0.0.0", port = int(config.FLASK_SERVER_PORT))
## File : server.py
