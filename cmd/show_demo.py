# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013 UnitedStack Co,.Ltd
## File : show_demo.py
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-14>
## Updated: Time-stamp: <2014-03-16 13:46:27>
##-------------------------------------------------------------------
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
import sys
import time

def open_url():
    driver = webdriver.Firefox()
    if sys.platform == "darwin":
        key = Keys.COMMAND
    else:
        key = Keys.CONTROL
    url_format="http://127.0.0.1:9181/list_topic?start_num=0&count=10&topic=%s"
    driver.get(url_format % "idea_startup")

    for category in ["coder_questions", "understand_us", "child_亲子教育"]:
        #item = driver.find_element_by_id("red-bar")
        item = driver.find_element_by_tag_name("body")
        item.send_keys(key + 't')
        driver.get(url_format % category)
        time.sleep(0.1)
    
    # inputElement = driver.find_element_by_id("kw")
    # inputElement.send_keys("sophia")
    # inputElement.submit()

if __name__=='__main__':
    open_url()

## File : show_demo.py ends
