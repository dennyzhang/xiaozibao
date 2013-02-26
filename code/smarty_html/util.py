# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : util.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-30 00:00:00>
## Updated: Time-stamp: <2013-02-13 22:40:53>
##-------------------------------------------------------------------
import logging
format = "%(asctime)s %(filename)s:%(lineno)d - %(levelname)s: %(message)s"
formatter = logging.Formatter(format)

consoleHandler = logging.StreamHandler()
consoleHandler.setLevel(logging.INFO)
consoleHandler.setFormatter(formatter)

log = logging.getLogger("smarty_html")
log.setLevel(logging.INFO)
log.addHandler(consoleHandler)

def is_english_leading(string):
    if len(string) == 0:
        return True

    ch = string[0]
    if ch >= 'A' and ch <= 'Z':
        return True
    if ch >= 'a' and ch <= 'z':
        return True
    return False

## File : util.py