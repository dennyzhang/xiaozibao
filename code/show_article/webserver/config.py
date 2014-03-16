# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : config.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-03-16 13:47:55>
##-------------------------------------------------------------------
################## global variable   #####################
import os

DB_HOST="127.0.0.1"
DB_USERNAME="user_2013"
DB_PWD="ilovechina"
DB_NAME="xzb"
FLASK_SERVER_PORT="9180"

DATA_BASEDIR = os.getcwd()+"/../../../webcrawler_data"

DATA_SEPARATOR="--text follows this line--"
MAX_LENGTH=10000
##########################################################
## File : config.py