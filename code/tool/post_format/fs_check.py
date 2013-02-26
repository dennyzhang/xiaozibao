# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : fs_check.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-02-16 16:33:57>
##-------------------------------------------------------------------
from util import log

def fs_check():
    log.info("Check the validation of post files")
    status, obj = check_duplicate_file()
    if status is False:
        log.error("There are some duplicate files, msg: %s" % obj)
        return False

    status, obj = check_posts_in_db()
    if status is False:
        log.error("Some files are not imported to db, msg: %s" % obj)
        return False

def check_duplicate_file():
    # TODO to be implemented
    return (True, True)

def check_posts_in_db():
    # TODO to be implemented
    return (True, True)

################  private functions ############################

################################################################
## File : db_check.py