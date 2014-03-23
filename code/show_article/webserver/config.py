# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : config.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-03-23 15:41:19>
##-------------------------------------------------------------------
################## global variable   #####################
import os

DB_HOST="127.0.0.1"
DB_USERNAME="user_2013"
DB_PWD="ilovechina"
DB_NAME="xzb"
FLASK_SERVER_PORT="9180"

XZB_HOME=os.environ.get('XZB_HOME')
assert(XZB_HOME != '')

DATA_BASEDIR = "%s/webcrawler_data" % (XZB_HOME)

DATA_SEPARATOR="--text follows this line--"
MAX_LENGTH=10000

SORT_METHOD_HOTEST="hotest"
SORT_METHOD_LATEST="latest"
##########################################################
## File : config.py