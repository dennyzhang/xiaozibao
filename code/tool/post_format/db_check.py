# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : db_check.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-02-02 17:06:04>
##-------------------------------------------------------------------
import MySQLdb
import config
from util import log

def db_check():
    log.info("Check whether all postid of deliver table is valid")
    status, obj = check_deliver_postid()
    if status is False:
        log.error("Some postid of deliver table is invalid, msg: %s" % obj)
        return False

    status, obj = check_posts_exists_in_fs()
    if status is False:
        log.error("Some posts of posts table doesn't exist in filesystem, msg: %s" % obj)
        return False

    return True

def get_postid_list():
    # TODO better way
    sql="select id from posts;"
    conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, config.DB_NAME, charset='utf8', port=3306)
    c=conn.cursor()
    c.execute(sql)
    out = c.fetchall()
    postid_list = []
    for obj in out:
        postid_list.append(obj[0])
    return postid_list

################  private functions ############################
def check_deliver_postid():
    # make sure delivers' postid can be found in posts table
    sql1="select count(1) from deliver left join posts on posts.id = deliver.id;"
    sql2="select count(1) from deliver inner join posts on posts.id = deliver.id;"
    conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, config.DB_NAME, charset='utf8', port=3306)
    c=conn.cursor()
    c.execute(sql1)
    out1 = c.fetchall()

    c=conn.cursor()
    c.execute(sql2)
    out2 = c.fetchall()

    if out1[0][0] != out2[0][0]:
        return (False, "Some postid of deliver table is invalid")

    return (True, True)

def check_posts_exists_in_fs():
    # TODO to be implemented
    return (True, True)

################################################################
## File : db_check.py