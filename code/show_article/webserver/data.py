# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : data.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-03-13 09:56:05>
##-------------------------------------------------------------------
import config
from util import POST
from util import fill_post_data, fill_post_meta
from sqlalchemy import create_engine

db = None

def create_db_engine():
    global db
    engine_str = "mysql://%s:%s@%s/%s" % (config.DB_USERNAME, \
                                          config.DB_PWD, config.DB_HOST, config.DB_NAME)
    db = create_engine(engine_str)

# sample: data.get_post("ffa72494d91aeb2e1153b64ac7fb961f")
def get_post(post_id):
    global db
    conn = db.connect()

    cursor = conn.execute("select id, category, title from posts where id ='%s'" % post_id)
    out = cursor.fetchall()
    conn.close()
    post = None
    if len(out) == 1:
        post = POST.list_to_post(out[0])
        fill_post_data(post)
        fill_post_meta(post)

    return post

def list_topic(topic, start_num, count, voteup, votedown):
    global db
    conn = db.connect()

    extra_where_clause = ""
    if voteup != -1:
        extra_where_clause = "%s and voteup = %d" % (extra_where_clause, voteup)
    if votedown != -1:
        extra_where_clause = "%s and votedown = %d" % (extra_where_clause, votedown)

    sql_format = "select posts.id, posts.category, posts.title from posts where category = '%s' %s order by num desc limit %d offset %d;"
    sql = sql_format % (topic, extra_where_clause, count, start_num)
    print sql
    cursor = conn.execute(sql)
    out = cursor.fetchall()
    conn.close()
    user_posts = POST.lists_to_posts(out)
    return user_posts

## File : data.py
