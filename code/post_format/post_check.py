# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : post_check.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-02-06 22:18:42>
##-------------------------------------------------------------------
from util import get_post
from util import log
from util import is_english_leading

import config
from db_check import get_postid_list

def post_check():
    log.info("Check post validation for all posts")
    postid_list = get_postid_list()
    status, obj = check_post_list(postid_list)
    if status is False:
        log.error("post check fail, msg: %s" % obj)
        return False

def check_post_list(postid_list):
    errmsg = ""
    for postid in postid_list:
        status, obj = check_post(postid)
        if status is False:
            errmsg = "%s\n%s" % (errmsg, obj)
    if errmsg == "":
        return (True, True)
    else:
        return (False, errmsg)

def check_post(postid):
    errmsg = ""
    status, obj = get_post(postid)
    if status is False:
        errmsg = "%s\n%s" % (errmsg, "fail to get post, postid: %s, msg: %s" % (postid, msg))

    status, obj = check_post_title(post['title'])
    if status is False:
        errmsg = "%s\n%s" % (errmsg, "check_post_title fail, msg: %s" % obj)

    status, obj = check_post_summary(post['summary'])
    if status is False:
        errmsg = "%s\n%s" % (errmsg, "check_post_summary fail, msg: %s" % obj)

    status, obj = check_post_content(post['content'])
    if status is False:
        errmsg = "%s\n%s" % (errmsg, "check_post_content fail, msg: %s" % obj)

    if errmsg == "":
        return (True, True)
    else:
        return (False, errmsg)

################  private functions ############################
def check_post_title(title):
    length=len(title)
    if is_english_leading(title):
        if length > config.MAX_LEN_TITLE*3:
            return (False, "Title is longer than %d: %s" % (config.MAX_LEN_TITLE*3, title))
            if length < config.MIN_LEN_TITLE:
                return (False, "Title is longer than %d: %s" % (config.MIN_LEN_TITLE*3, title))
    else:
        if length > config.MAX_LEN_TITLE:
            return (False, "Title is longer than %d: %s" % (config.MAX_LEN_TITLE, title))
        if length < config.MIN_LEN_TITLE:
            return (False, "Title is longer than %d: %s" % (config.MIN_LEN_TITLE, title))

    return (True, True)

def check_post_summary(summary):
    length=len(summary)
    if is_english_leading(summary):
        if length > config.MAX_LEN_SUMMARY*3:
            return (False, "Summary is longer than %d: %s" % (config.MAX_LEN_SUMMARY*3, summary))
            if length < config.MIN_LEN_SUMMARY:
                return (False, "Summary is longer than %d: %s" % (config.MIN_LEN_SUMMARY*3, summary))
    else:
        if length > config.MAX_LEN_SUMMARY:
            return (False, "Summary is longer than %d: %s" % (config.MAX_LEN_SUMMARY, summary))
        if length < config.MIN_LEN_SUMMARY:
            return (False, "Summary is longer than %d: %s" % (config.MIN_LEN_SUMMARY, summary))

    return (True, True)

def check_post_content(content):
    length=len(content)
    if length > config.MAX_LEN_CONTENT:
        return (False, "Summary is longer than %d: %s" % (config.MAX_LEN_CONTENT, summary))

    if length < config.MIN_LEN_CONTENT:
        return (False, "Content is longer than %d: %s" % (config.MIN_LEN_CONTENT, content))

    for filter_regexp in config.CONTENT_FILTER_REGEXP_LIST:
        # TODO regexp
        if content.find(filter_regexp) != -1:
            return (False, "Content has %s, which is normally forbidden" % (filter_regexp))
    return (True, True)

################################################################
## File : post_check.py