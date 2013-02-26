# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : data.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2013-02-18 18:06:52>
##-------------------------------------------------------------------
import MySQLdb
import config
from util import POST
from util import fill_post_data
from util import fill_post_meta

# sample: data.get_post("ffa72494d91aeb2e1153b64ac7fb961f")
def get_post(id):
    conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, config.DB_NAME, charset='utf8', port=3306)
    c=conn.cursor()
    c.execute("select id, category, title from posts where id ='%s'" % id)
    out = c.fetchall()
    # TODO close db connection
    # TODO: defensive check
    post = POST.list_to_post(out[0])
    fill_post_data(post)
    fill_post_meta(post)
    return post

def list_user_post(userid, date):
    conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, config.DB_NAME, charset='utf8', port=3306)
    c=conn.cursor()
    if date == '':
        sql = "select posts.id, posts.category, posts.title " + \
              "from deliver inner join posts on deliver.id = posts.id " + \
              "where userid='%s' order by deliver_date desc" % (userid)
    else:
        sql = "select posts.id, posts.category, posts.title " + \
              "from deliver inner join posts on deliver.id = posts.id " + \
              "where userid='%s' and deliver_date='%s' order by deliver_date desc" % (userid, date)
    c.execute(sql)
    out = c.fetchall();
    user_posts = POST.lists_to_posts(out)

    if date == '':
        sql = "select posts.id, posts.category, posts.title " + \
              "from deliver, posts, user_group " +\
              "where deliver.id = posts.id and user_group.userid='%s' " +\
              "and user_group.groupid=deliver.userid " +\
              "order by deliver_date desc; " % (userid)

    else:
        sql = "select posts.id, posts.category, posts.title " + \
              "from deliver, posts, user_group " +\
              "where deliver.id = posts.id and user_group.groupid=deliver.userid and " +\
              "user_group.userid='%s' and deliver_date='%s' order by deliver_date desc;" %(userid, date)

    c.execute(sql)
    out = c.fetchall();
    group_posts = POST.lists_to_posts(out)

    return user_posts + group_posts
## File : data.py