# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : data.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-03-29 12:12:54>
##-------------------------------------------------------------------
import config
from util import POST
from util import fill_post_data, fill_post_meta
from sqlalchemy import create_engine
from util import log

db = None

def create_db_engine():
    global db
    engine_str = "mysql://%s:%s@%s/%s?charset=utf8" % (config.DB_USERNAME, \
                                          config.DB_PWD, config.DB_HOST, config.DB_NAME)
    db = create_engine(engine_str)

# sample: data.get_post("ffa72494d91aeb2e1153b64ac7fb961f")
def get_post(post_id):
    global db
    conn = db.connect()

    cursor = conn.execute("select id, category, title, filename from posts where id ='%s'" % post_id)
    out = cursor.fetchall()
    conn.close()
    post = None
    if len(out) == 1:
        post = POST.list_to_post(out[0])
        fill_post_data(post)
        fill_post_meta(post)

    return post

def list_topic(topic, start_num, count, voteup, votedown, sort_method):
    global db
    conn = db.connect()

    sql_clause = "select id, category, title, filename from posts "

    where_clause = "where category ='%s'" % (topic)
    extra_where_clause = ""
    if voteup != -1:
        extra_where_clause = "%s and voteup = %d" % (extra_where_clause, voteup)
    if votedown != -1:
        extra_where_clause = "%s and votedown = %d" % (extra_where_clause, votedown)
    where_clause = "%s%s" % (where_clause, extra_where_clause)

    orderby_clause = " "
    if sort_method == config.SORT_METHOD_LATEST:
        orderby_clause = "order by voteup asc, votedown asc"

    if sort_method == config.SORT_METHOD_HOTEST:
        orderby_clause = "order by voteup desc, votedown desc"

    sql = "%s %s %s limit %d offset %d;" % (sql_clause, where_clause, orderby_clause, count, start_num)
    log.info(sql)
    cursor = conn.execute(sql)
    out = cursor.fetchall()
    conn.close()
    user_posts = POST.lists_to_posts(out)
    return user_posts

## File : data.py
