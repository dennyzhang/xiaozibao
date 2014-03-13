# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013 UnitedStack Co,.Ltd
## File : update_post_feedback.py
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-03-12>
## Updated: Time-stamp: <2014-03-12 23:15:37>
##-------------------------------------------------------------------
import sys
from sqlalchemy import create_engine

DB_HOST="127.0.0.1"
DB_USERNAME="user_2013"
DB_PWD="ilovechina"
DB_NAME="xzb"

engine_str = "mysql://%s:%s@%s/%s" % (DB_USERNAME, DB_PWD, DB_HOST, DB_NAME)

def clean_old_feedback_first():
    db = create_engine(engine_str)
    conn = db.connect()
    cursor = conn.execute("update posts set voteup=0, votedown=0")
    conn.close()

def update_feedback_by_logfile(logfile):
    MAX_PARSE_COUNT=10000
    i = 0;
    voteup_dict = { }
    votedown_dict = { }
    with open(logfile, 'r') as f:
        for row in f:
            items = row.split(' ')
            postid = items[0]
            category = items[1]
            comment = ' '.join(items[2:])

            if comment.find('votedown') != -1:
                votedown_dict[postid] = votedown_dict.get(postid, 0) + 1
            if comment.find('voteup') != -1:
                voteup_dict[postid] = voteup_dict.get(postid, 0) + 1

            i += 1;
            if (i >= MAX_PARSE_COUNT):
                update_feedback(voteup_dict, votedown_dict)
                i = 0;
                votedown_dict = { }
                voteup_dict = { }

    update_feedback(voteup_dict, votedown_dict)

def update_feedback(voteup_dict, votedown_dict):
    db = create_engine(engine_str)
    conn = db.connect()

    if len(voteup_dict) != 0:
        for postid in voteup_dict.keys():
            cursor = conn.execute("update posts set voteup=voteup+%d where id='%s'" % (voteup_dict[postid], postid))

    if len(votedown_dict) != 0:
        for postid in votedown_dict.keys():
            cursor = conn.execute("update posts set votedown=votedown+%d where id='%s'" % (votedown_dict[postid], postid))

    conn.close()

if __name__=='__main__':
    if '--clean_first' in sys.argv:
        clean_old_feedback_first()

    update_feedback_by_logfile(sys.argv[1])

## File : update_post_feedback.py ends
