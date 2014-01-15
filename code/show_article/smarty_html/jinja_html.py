# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013
## File : jinja_html.py
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-01-30 00:00:00>
## Updated: Time-stamp: <2014-01-15 12:54:52>
##-------------------------------------------------------------------
from jinja2 import Template
from urllib2 import urlopen
from string import split
import json
import codecs
from markdown import markdown

from util import log
from util import is_english_leading
import config

import sys
default_encoding = 'utf-8'
if sys.getdefaultencoding() != default_encoding:
    reload(sys)
    sys.setdefaultencoding(default_encoding)

# sample: jinja_html.generate_list_user_post("denny", "2013-01-24", "/tmp/test.html")
def generate_list_user_post(userid, date, dst_html, host=config.DB_HOST, port=config.FLASK_SERVER_PORT):
    url = "http://%s:%s/api_list_user_post?userid=%s&date=%s" % (host, port, userid, date)
    generate_html(url, dst_html, [date])

# sample: jinja_html.generate_user_all_posts("denny", "2013-01-24", "/tmp/")
def generate_user_all_posts(userid, date, dst_dir, host=config.DB_HOST, port=config.FLASK_SERVER_PORT):
    url = "http://%s:%s/api_list_user_post?userid=%s&date=%s" % (host, port, userid, date)
    (status, json_obj) = request_json(url)
    for post in json_obj:
        url = "http://%s:%s/api_get_post?id=%s" % (host, port, post['id'])
        generate_html(url, "%s/%s.html" % (dst_dir, post['id']), [date])

# sample: jinja_html.generate_html("http://127.0.0.1:9080/api_list_user_post?userid=denny&date=2013-01-24", "/tmp/test.html")
# sample: jinja_html.generate_html("http://127.0.0.1:9080/api_get_post?id=c83191cbde5b5b465b62003bb1c79d3a", "/tmp/test.html")
def generate_html(url, dst_html, arg_list = []):
    # TODO
    if len(arg_list) == 0: 
        date = '2014-01-12'
    else:
        date = arg_list[0]

    method = get_http_get_method(url)
    if method == "api_get_post":
        template_html = "templates/%s.html" % method
    else:
        template_html = "templates/%s.html" % "api_list_post"
    log.info("begin to generate_html from %s to %s with url(%s)" % (template_html, dst_html, url))
    # get http result
    (status, json_obj) = request_json(url)
    # TODO: better way for reporting errors
    if status is False:
        log.error("error: %s" % json_obj)
        return False

    # jinja template
    (status, template_string) = read_file(template_html)
    if status is False:
        log.error("error: %s" % template_string)
        return False

    template = Template(template_string)

    if method=="api_get_post":
        json_obj['title'] = beautify_title(json_obj['title'])
        json_obj['summary'] = beautify_summary(json_obj['summary'])
        json_obj['content'] = beautify_content(json_obj['content'])
        output_str = template.render(date=convert_chinese_date(date), \
                                     issue="000", post=json_obj, version = config.HTML_VERSION)

    else:
        for post in json_obj:
            post['title'] = beautify_title(post['title'])
            post['summary'] = beautify_summary(post['summary'])
        output_str = template.render(date=convert_chinese_date(date), \
                                     issue="000", posts=json_obj, version = config.HTML_VERSION)

    # generate html
    (status, value) = write_file(dst_html, output_str)
    if status is False:
        log.error("error: %s" % value)
        return False
    log.info("Successfully generate %s from %s with url(%s)" % (dst_html, template_html, url))
    return True

def beautify_content(string):
    ret = ""
    if string.find("\n*") == -1:
        ret =  string.replace('\n', "<br/>")
    else:
        ret = markdown(string)
    ret = markdown(string) ## TODO
    return ret

def beautify_title(string):
    str_ret = string
    if is_english_leading(string):
        if len(string) > config.MAX_LEN_TITLE * 3:
            str_ret = string[0:config.MAX_LEN_TITLE*3] + "..."
    else:
        if len(string) > config.MAX_LEN_TITLE:
            str_ret = string[0:config.MAX_LEN_TITLE] + "..."
    return str_ret

def beautify_summary(string):
    str_ret = string
    if is_english_leading(string):
        if len(string) > config.MAX_LEN_SUMMARY * 3:
            str_ret = string[0:config.MAX_LEN_SUMMARY*3] + "..."
    else:
        if len(string) > config.MAX_LEN_SUMMARY:
            str_ret = string[0:config.MAX_LEN_SUMMARY] + "..."
    return str_ret

################  private functions ############################
def get_http_get_method(url):
    url = split(url, "?")[0]
    return split(url, "/")[-1]

def chinese_num(ch):
    if ch=='0': return '〇'
    if ch=='1': return '一'
    if ch=='2': return '二'
    if ch=='3': return '三'
    if ch=='4': return '四'
    if ch=='5': return '五'
    if ch=='6': return '六'
    if ch=='7': return '七'
    if ch=='8': return '八'
    if ch=='9': return '九'
    if ch=='-': return '·'
    return ch

# convert_chinese_date('2013-1-30') -> "二〇一三·一·三十"
def convert_chinese_date(date):
    chinese_date=""
    for c in date:
        # TODO better way
        chinese_date=chinese_date+chinese_num(c)
    chinese_date = chinese_date.replace("·〇", "·")
    return chinese_date

def request_json(url):
    content = urlopen(url).read() # TODO: defensive coding
    content = content.decode('utf-8') # TODO: more effcient way

    # decode json
    json_obj = json.loads(content) # TODO: defensive coding
    return (True, json_obj)

def write_file(fname, content):
    fout = codecs.open(fname, "wb", "utf-8") # TODO: defensive coding
    fout.write(content)
    fout.close()
    return (True, True)

def read_file(fname):
    fin = open(fname, "rb") # TODO: defensive coding
    template_string = unicode(fin.read(10000), "utf-8") ## TODO better way
    fin.close()
    return (True, template_string)
################################################################

if __name__ == "__main__":
    print "hello, world"

## File : jinja_html.py
