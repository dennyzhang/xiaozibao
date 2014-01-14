# -*- coding: utf-8 -*-
#!/usr/bin/python
##-------------------------------------------------------------------
## @copyright 2013 UnitedStack Co,.Ltd
## File : show_demo.py
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-14>
## Updated: Time-stamp: <2014-01-14 17:41:21>
##-------------------------------------------------------------------
from selenium import webdriver

def open_url(url):
    from selenium import webdriver
    driver = webdriver.Firefox()
    driver.get(url)
    # inputElement = driver.find_element_by_id("kw")
    # inputElement.send_keys("sophia")
    # inputElement.submit()

if __name__=='__main__':
    open_url("http://127.0.0.1:9081/list_topic?topic=idea_startup&start_num=0&count=10")

## File : show_demo.py ends
