# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013 UnitedStack Co,.Ltd
## File : update_post_feedback.py
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-03-12>
## Updated: Time-stamp: <2014-03-29 13:31:45>
##-------------------------------------------------------------------
import sys
from sqlalchemy import create_engine
import os
import time
import fnmatch

import sys
import logging
log = logging.getLogger("update_post_feedback")
format = "L:%(lineno)d - %(levelname)s: %(message)s"
formatter = logging.Formatter(format)
stream_handler = logging.StreamHandler(sys.stdout)
stream_handler.setFormatter(formatter)
log.addHandler(stream_handler)
#log.setLevel(logging.INFO)
log.setLevel(logging.ERROR)

XZB_HOME=os.environ.get('XZB_HOME')
assert(XZB_HOME != '')

DATA_BASEDIR = "%s/webcrawler_data" % (XZB_HOME)

DB_HOST="127.0.0.1"
DB_USERNAME="user_2013"
DB_PWD="ilovechina"
DB_NAME="xzb"

EDITOR_UID_LIST = ["denny", "749A51E0-50F4-49AD-A5D5-BDCBA787EF29", "0DD7936F-629C-4E9E-B458-821B3964EA3E"]

FIELD_SEPARATOR="&$!"
FEEDBACK_ENVOTEUP="tag envoteup"
FEEDBACK_ENVOTEDOWN="tag envotedown"
FEEDBACK_ENFAVORITE="tag enfavorite"
FEEDBACK_DEVOTEUP="tag devoteup"
FEEDBACK_DEVOTEDOWN="tag devotedown"
FEEDBACK_DEFAVORITE="tag defavorite"
META_LEADING_STRING="meta:"

FLAGFILE="flagfile_modifytime"

def get_post_filename_byid(postid, category):
    global conn
    cursor = conn.execute("select postid, category, title, filename from posts where postid ='%s' and category='%s'" % \
                          (postid, category))
    out = cursor.fetchall()
    if len(out) != 1:
        return "";

    filename = out[0][3]
    return "%s/%s" % (DATA_BASEDIR, filename)

def parse_feedback_logfile(logfile):
    with open(logfile, 'r') as f:
        for row in f:
            if row == "\n":
                continue
            metadata_dict = {}
            for field in row.split(FIELD_SEPARATOR):
                field = field.strip(' \n')
                #print field
                key, value = field.split('=')
                metadata_dict[key] = value

            yield metadata_dict

def get_post_metdata_dict(postid, category, fname):
    metadata_dict = {}
    if fname == "":
        log.warn("Warning: fail to find related file for postid(%s)" % (postid))
        return None

    with open(fname,'r') as f:
        for row in f:
            if row.find(META_LEADING_STRING) == 0:
                meta_str = row[len(META_LEADING_STRING):].strip(' ')
                if meta_str == "\n":
                    break
                for field in meta_str.split('&'):
                    # print field
                    key, value = field.split('=')
                    metadata_dict[key.strip(' ')] = value.strip(' \n')
                break

    #print metadata_dict
    return metadata_dict

def update_post_metadata_file(postid, category, fname, metadata_dict):
    with open(fname) as f:
        lines = f.readlines()
    count = len(lines)

    # build meta_str
    meta_str = ""
    for key in metadata_dict.keys():
        meta_str = "%s&%s=%s" % (meta_str, key, str(metadata_dict[key]))
    if meta_str !="":
        meta_str = meta_str[1:]
    meta_str = "%s %s\n" % (META_LEADING_STRING, meta_str)

    #print metadata_dict

    # in place change to the file
    find_meta = False
    for i in xrange(0, count):
        if lines[i].find(META_LEADING_STRING) == 0:
            find_meta = True
            lines[i] = meta_str
            break

    log.info("update file with find_meta:%d, meta_str:%s" % (find_meta, meta_str))
        
    with open(fname, "wab") as f:
        if find_meta is False:
            f.write(meta_str)
        for i in xrange(0, count):
            f.write(lines[i])
            # print lines[i]

def update_post_metadata_db(postid, category, metadata_dict):
    global conn
    update_clause = ""
    for key in metadata_dict.keys():
        if key in ['postid', 'category']:
            continue
        value = metadata_dict[key]
        if isinstance(value, str):
            update_clause = "%s and %s='%s'" % (update_clause, key, value)
        else:
            update_clause = "%s and %s=%s" % (update_clause, key, value)

    if update_clause != "":
        update_clause = update_clause[len(" and "):]

    sql = "update posts set %s where postid='%s' and category='%s'" % \
          (update_clause, metadata_dict["postid"], metadata_dict["category"])
    log.info(sql)
    cursor = conn.execute(sql)

def update_feedback_by_logfile(logfile):
    log.info("update_feedback_by_logfile, logfile:%s" % (logfile))
    for dict_log in parse_feedback_logfile(logfile):
        #print dict_log
        postid = dict_log["postid"]
        category = dict_log["category"]
        fname = get_post_filename_byid(postid, category)
        dict_file = get_post_metdata_dict(postid, category, fname)
        if dict_file is None:
            continue
        dict_new = caculate_meta(dict_file, dict_log)
        # write back result to file and db
        update_post_metadata_file(postid, category, fname, dict_new)
        dict_db = {}
        dict_db["postid"] = postid
        dict_db["category"] = category
        dict_db["voteup"] = dict_new["voteup"]
        dict_db["votedown"] = dict_new["votedown"]
        update_post_metadata_db(postid, category, dict_db)

def caculate_meta(dict_file, dict_log):
    global modifytime
    # TODO: better way
    dict_new = {}
    for key in dict_file.keys():
        dict_new[key] = dict_file[key]
        # regenerate dict
        if (dict_file.has_key('modifytime') is False) or modifytime > (int)(dict_file["modifytime"]):
            dict_new["voteup"] = 0
            dict_new["votedown"] = 0
            dict_new["favorite"] = 0

    comment = dict_log["comment"]
    uid = dict_log["uid"]

    effect_rate = 1
    if not (uid in EDITOR_UID_LIST):
        effect_rate = 0

    postid = dict_log["postid"]
    category = dict_log["category"]
    
    dict_new["modifytime"] = modifytime
    if dict_new.has_key("voteup") is False:
        dict_new["voteup"] = 0
    else:
        dict_new["voteup"] = int(dict_new["voteup"])

    if dict_new.has_key("votedown") is False:
        dict_new["votedown"] = 0
    else:
        dict_new["votedown"] = int(dict_new["votedown"])

    if dict_new.has_key("favorite") is False:
        dict_new["favorite"] = 0
    else:
        dict_new["favorite"] = int(dict_new["favorite"])

    if comment.find(FEEDBACK_ENVOTEUP) == 0:
        dict_new["voteup"] += effect_rate;
    if comment.find(FEEDBACK_DEVOTEUP) == 0:
        dict_new["voteup"] -= effect_rate;

    if comment.find(FEEDBACK_ENVOTEDOWN) == 0:
        dict_new["votedown"] += effect_rate;
    if comment.find(FEEDBACK_DEVOTEDOWN) == 0:
        dict_new["votedown"] -= effect_rate;

    if comment.find(FEEDBACK_ENFAVORITE) == 0:
        dict_new["favorite"] += effect_rate;
    if comment.find(FEEDBACK_DEFAVORITE) == 0:
        dict_new["favorite"] -= effect_rate;

    return dict_new

if __name__=='__main__':

    global modifytime
    modifytime = int(round(time.time()))
    engine_str = "mysql://%s:%s@%s/%s" % (DB_USERNAME, DB_PWD, DB_HOST, DB_NAME)
    db = create_engine(engine_str)
    global conn
    conn = db.connect()

    command = sys.argv[1]
    # print "command:%s" % (command)
    if command == "generate_flagfile":
        print "generage %s with %d" %(FLAGFILE, modifytime)
        open(FLAGFILE, "wab").write(str(modifytime))

    if command == "clean_flagfile":
        if os.path.exists(FLAGFILE):
            os.remove(FLAGFILE)

    if command == "update_feedback":
        if os.path.exists(FLAGFILE):
            with open(FLAGFILE,'r') as f:
                content = f.readlines()
                modifytime = int(content[0])
                #print modifytime
                update_feedback_by_logfile(sys.argv[2])
    conn.close()

## File : update_post_feedback.py ends
