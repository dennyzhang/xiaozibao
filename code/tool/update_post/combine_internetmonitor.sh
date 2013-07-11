#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013
## File : combine_internetmonitor.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-02-01>
## Updated: Time-stamp: <2013-07-11 17:43:35>
##-------------------------------------------------------------------
. /usr/bin/utility_xzb.sh

# export GOPATH=$XZB_HOME/code/webcrawl_article/webcrawler; cd $GOPATH; for((i=1; i< 51; i++)); do { go run ./src/main.go "http://www.zhihu.com/topic/19551627/top-answers?page=$i"; sleep 600;}; done

function update_internetmonitor() {
    log "update_internetmonitor"

    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/nanchang.html -d internetmonitor/webcrawler_raw_pm;

    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=上海+天气 -d internetmonitor/webcrawler_raw_baidu;
    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=昆明+天气 -d internetmonitor/webcrawler_raw_baidu;
    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=南京+天气 -d internetmonitor/webcrawler_raw_baidu;
    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=台州+天气 -d internetmonitor/webcrawler_raw_baidu;
    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=南昌+天气 -d internetmonitor/webcrawler_raw_baidu;
    sudo xzb_fetch_url.sh -f http://www.baidu.com/s?wd=长沙+天气 -d internetmonitor/webcrawler_raw_baidu;

    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/changsha.html -d internetmonitor/webcrawler_raw_pm;
    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/shanghai.html -d internetmonitor/webcrawler_raw_pm;
    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/kunming.html -d internetmonitor/webcrawler_raw_pm;
    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/taizhou.html -d internetmonitor/webcrawler_raw_pm;
    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/nanjing.html -d internetmonitor/webcrawler_raw_pm;
    sudo xzb_fetch_url.sh -f http://www.pm2d5.com/city/nanchang.html -d internetmonitor/webcrawler_raw_pm;

    #sudo xzb_fetch_url.sh -f http://stock.stcn.com/sh/600362/ -d internetmonitor/webcrawler_raw_stock;

    sudo xzb_fetch_url.sh -f http://www.google.com/finance?q=nvidia -d internetmonitor/webcrawler_raw_stock;
    sudo xzb_fetch_url.sh -f http://www.google.com/finance?q=intel -d internetmonitor/webcrawler_raw_stock;
    sudo xzb_fetch_url.sh -f http://www.google.com/finance?q=marvell -d internetmonitor/webcrawler_raw_stock;
    sudo xzb_fetch_url.sh -f http://www.google.com/finance?q=amd -d internetmonitor/webcrawler_raw_stock;
}

function combine_internetmonitor() {
    userid=${1?}
    location=${2?}
    dst_dir=$XZB_HOME/data
    cd $XZB_HOME/webcrawler_data;
    > "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_baidu/$location 天气.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_pm/$location PM.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/江西铜业 股票.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
}

function combine_internetmonitor_colin() {
    userid=${1?}
    location=${2?}
    dst_dir=$XZB_HOME/data
    cd $XZB_HOME/webcrawler_data;
    > "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_baidu/$location 天气.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_pm/$location PM.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/Advanced Micro Devices, Inc..data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/Marvell Technology Group Ltd..data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/Intel Corporation.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/NVIDIA Corporation.data" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    cat "./internetmonitor/webcrawler_raw_stock/江西铜业 股票.data" >> "$dst_di$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    echo -e "\n" >> "$dst_dir/internetmonitor/$userid's Internet Monitor.data"

    sed -ie 's/id:.*//g' "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    sed -ie 's/source:.*//g' "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    sed -ie 's/summary:.*//g' "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
    sed -ie 's/.*text follows this line.*//g' "$dst_dir/internetmonitor/$userid's Internet Monitor.data"
}

update_internetmonitor

log "combine_internetmonitor"
combine_internetmonitor "denny" "上海"
combine_internetmonitor "liki" "上海"
combine_internetmonitor "sophia" "上海"
combine_internetmonitor_colin "colin" "上海"
combine_internetmonitor "allen" "台州"
combine_internetmonitor "yao" "南京"
combine_internetmonitor "haijun" "长沙"

combine_internetmonitor "zan" "上海"
combine_internetmonitor "ning" "南昌"
combine_internetmonitor "sjembn" "上海"
# combine_internetmonitor "grace" "上海"
combine_internetmonitor "clare" "上海"
combine_internetmonitor "jim" "上海"
combine_internetmonitor "yuki" "上海"

## File : combine_internetmonitor.sh ends
