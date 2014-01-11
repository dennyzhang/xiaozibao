# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : data.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-25 00:00:00>
## Updated: Time-stamp: <2014-01-11 12:52:19>
##-------------------------------------------------------------------
import MySQLdb
import config
from util import POST
from util import fill_post_data
from util import fill_post_meta

# sample: data.get_post("ffa72494d91aeb2e1153b64ac7fb961f")
def get_post(post_id):
	conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, \
						 config.DB_PWD, config.DB_NAME, charset='utf8', port=3306)
	cursor = conn.cursor()
	cursor.execute("select id, category, title from posts where id ='%s'" % post_id)
	out = cursor.fetchall()
	cursor.close()
	# todo: defensive check
	post = POST.list_to_post(out[0])
	fill_post_data(post)
	fill_post_meta(post)
	return post

def list_user_post(userid, date):
	conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, \
						 config.DB_NAME, charset='utf8', port=3306)
	cursor = conn.cursor()
	if date == '':
		sql = "select posts.id, posts.category, posts.title " + \
			"from deliver inner join posts on deliver.id = posts.id " + \
			"where userid='{0}' order by deliver_date desc".format(userid)
	else:
		sql = "select posts.id, posts.category, posts.title " + \
			"from deliver inner join posts on deliver.id = posts.id " + \
			"where userid='{0}' and deliver_date='{1}' order by deliver_date desc".format(userid, date)
	cursor.execute(sql)
	out = cursor.fetchall()
	user_posts = POST.lists_to_posts(out)

	if date == '':
		sql = "select posts.id, posts.category, posts.title " + \
			"from deliver, posts, user_group " +\
			"where deliver.id = posts.id and user_group.userid='{0}' " +\
			"and user_group.groupid=deliver.userid " +\
			"order by deliver_date desc; ".format(userid)

	else:
		sql = "select posts.id, posts.category, posts.title " + \
			"from deliver, posts, user_group " +\
			"where deliver.id = posts.id and user_group.groupid=deliver.userid and " +\
			"user_group.userid='{0}' and deliver_date='{1}' order by deliver_date desc;".format(userid, date)

	cursor.execute(sql)
	out = cursor.fetchall()
	cursor.close()
	group_posts = POST.lists_to_posts(out)

	return user_posts + group_posts

def list_user_topic(userid, topic, start_num, count):
	conn = MySQLdb.connect(config.DB_HOST, config.DB_USERNAME, config.DB_PWD, \
			config.DB_NAME, charset='utf8', port=3306)
	cursor = conn.cursor()
	sql_format = "select id from posts where category = '%s' order by num desc limit %d offset %d;"
	sql = sql_format % (topic, count, start_num)
	print sql
	cursor.execute(sql)
	out = cursor.fetchall()
	cursor.close()
	return out
## File : data.py
