# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : util.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-02-05 11:17:11>
##-------------------------------------------------------------------
from urllib2 import urlopen
import json

import config

import logging
format = "%(asctime)s %(filename)s:%(lineno)d - %(levelname)s: %(message)s"
formatter = logging.Formatter(format)

consoleHandler = logging.StreamHandler()
consoleHandler.setLevel(logging.INFO)
consoleHandler.setFormatter(formatter)

log = logging.getLogger("post_format")
log.setLevel(logging.INFO)
log.addHandler(consoleHandler)

def get_post(postid, host=config.DB_HOST, port=config.FLASK_SERVER_PORT):
    url = "http://%s:%s/api_get_post?id=%s" % (host, port, postid)
    return request_json(url)

def is_english_leading(string):
    ch = string[0]
    if ch >= 'A' and ch <= 'Z':
        return True
    if ch >= 'a' and ch <= 'z':
        return True
    return False

################  private functions ############################
def request_json(url):
    content = urlopen(url).read() # TODO: defensive coding
    content = content.decode('utf-8') # TODO: more effcient way

    # decode json
    json_obj = json.loads(content) # TODO: defensive coding
    return (True, json_obj)

################################################################
## File : util.py