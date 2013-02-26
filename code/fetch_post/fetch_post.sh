#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : fetch_post.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-02-21 14:52:02>
##-------------------------------------------------------------------
. /usr/bin/utility_xzb.sh

. fetch_post_utility.sh
function fetch_danmei() {
    log "generate url fetch tasks of danmei"
    #fetch_weibo "danmei_耽美微小说/weibo_glbl" "glbl" "$(generate_seq 1 304)"
    #fetch_weibo "danmei_耽美微小说/weibo_piaoxiangyuan" "piaoxiangyuan" "$(generate_seq 1 13)"
    #fetch_haowenz "danmei_耽美微小说/haowenz" "1 2 3 4 5"
    #fetch_weibo_search "danmei_耽美微小说/weibo_search_#耽美微小说#" "%2523%25E8%2580%25BD%25E7%25BE%258E%25E5%25BE%25AE%25E5%25B0%258F%25E8%25AF%25B4%2523" "$(generate_seq 1 50)"
}

function fetch_fun() {
    log "generate url fetch tasks of fun"
    # fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_娱乐" "19553632" "1 2 3 4 5 6"
    # fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_娱乐" "19553632" "7 8 9 10 11 12 13 14 15 16"
    # fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_冷知识" "19569420" "1 2 3 4 5 6"
}

function fetch_joke() {
    log "generate url fetch tasks of joke"
    # fetch_zhihu "joke_笑话/webcrawler_raw_zhihu_笑话" "19563616" "1 2 3"
    # fetch_zhihu "joke_笑话/webcrawler_raw_zhihu_搞笑" "19610713" "1 2"
    # fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲热笑话" "LXH" "0"
    # fetch_douban "joke_笑话/webcrawler_raw_douban_我们就是冷笑话" "57157" "0"
    # fetch_douban "joke_笑话/webcrawler_raw_douban_给女朋友说冷笑话 o_0 " "57157" "sillyjokes"
    # fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲冷笑话" "Gia-club" "0 25 75 100"
    # fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲冷笑话tm" "Yi-club" "0 25 75 100"
    # fetch_weibo_search "joke_笑话/weibo_search_#精选笑话#" "%2523%25E7%25B2%25BE%25E9%2580%2589%25E7%25AC%2591%25E8%25AF%259D%2523" "$(generate_seq 1 22)"
    # fetch_weibo "joke_笑话/weibo_冷笑话rmlxh" "2824339867" "1 2 3 4"
    # fetch_weibo "joke_笑话/weibo_热门笑话搜罗" "kenneylove" "$(generate_seq 1 33)" ## 质量不行
    # fetch_weibo "joke_笑话/weibo_热门笑话斋" "2368307107" "$(generate_seq 1 218)"
    # fetch_weibo "joke_笑话/weibo_冷笑话幽默搞笑选" "2507161702" "$(generate_seq 1 327)"
    # fetch_weibo "joke_笑话/weibo_魂淡是怎样练成的" "3002847684" "$(generate_seq 1 13)"
    # fetch_weibo_direct_user "joke_笑话/weibo_最幽默排行榜" "612072220" "$(generate_seq 1 865)"
    # fetch_weibo_direct_user "joke_笑话/weibo_两性内涵幽默" "siwajizhongying" "$(generate_seq 1 73)"
}

function fetch_parent() {
    log "generate url fetch tasks of parent"
    # fetch_zhihu "parent_赡养父母/webcrawler_raw_zhihu_父母" "19589532" "1 2 3 4 5 6 7 8 9 10"
}

function fetch_child() {
    log "generate url fetch tasks of child"
    # fetch_zhihu "child_亲子教育/webcrawler_raw_zhihu_亲子" "19559632" "1 2 3 4 5 6"
    # fetch_douban_discussion "child_亲子教育/webcrawler_raw_douban_轻松父母123" "214243" "0 25 50"
}

function fetch_spouse() {
    log "generate url fetch tasks of spouse"
    # fetch_zhihu "spouse_伴侣/webcrawler_raw_zhihu_两性关系" "19556421" "1 2 3 4 5 6 7 8 9 10"
    # fetch_zhihu "spouse_伴侣/webcrawler_raw_zhihu_两性关系" "19556421" "11 12 13 14 15 16"
    # fetch_zhihu "spouse_伴侣/webcrawler_raw_zhihu_两性关系" "19556421" "$(generate_seq 17 27)"
    # fetch_zhihu "spouse_伴侣/webcrawler_raw_zhihu_两性关系" "19556421" "$(generate_seq 28 38)"

    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_恋爱 婚姻 家庭" "21714" "0"
    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_婚姻、恋爱、人生" "281331" "0"
    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_打垮小三" "160105" "0"
    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_恋爱心理学" "ralationship" "0"
    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_嫁人就嫁程序员" "program" "0"
    # fetch_douban "spouse_伴侣/webcrawler_raw_douban_夫妻兵法" "marriage" "0"
}

function fetch_food() {
    log "generate url fetch tasks of food"
    # fetch_zhihu "food_美食/webcrawler_raw_zhihu_美食" "19551137" "1 2 3 4 5 6"
    # fetch_zhihu "food_美食/webcrawler_raw_zhihu_美食" "19551137" "$(generate_seq 7 17)"
}

function fetch_movie() {
    log "generate url fetch tasks of movie"
    # fetch_zhihu "movie_电影/webcrawler_raw_zhihu_电影" "19550429" "1 2 3 4 5 6"
    # fetch_zhihu "movie_电影/webcrawler_raw_zhihu_电影" "19550429" "7 8 9 10 11 12"
}

fetch_danmei
fetch_joke
fetch_parent
fetch_child
fetch_spouse
fetch_food
fetch_movie
fetch_fun
## File : fetch_danmei.sh ends
