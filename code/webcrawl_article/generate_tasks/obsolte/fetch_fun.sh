. /usr/bin/utility_xzb.sh
. utility/fetch_post_utility.sh

fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_娱乐" "19553632" "1 2 3 4 5 6"
fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_娱乐" "19553632" "7 8 9 10 11 12 13 14 15 16"
fetch_zhihu "fun_娱乐/webcrawler_raw_zhihu_冷知识" "19569420" "1 2 3 4 5 6"
fetch_zhihu "joke_笑话/webcrawler_raw_zhihu_笑话" "19563616" "1 2 3"
fetch_zhihu "joke_笑话/webcrawler_raw_zhihu_搞笑" "19610713" "1 2"
fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲热笑话" "LXH" "0"
fetch_douban "joke_笑话/webcrawler_raw_douban_我们就是冷笑话" "57157" "0"
fetch_douban "joke_笑话/webcrawler_raw_douban_给女朋友说冷笑话 o_0 " "57157" "sillyjokes"
fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲冷笑话" "Gia-club" "0 25 75 100"
fetch_douban "joke_笑话/webcrawler_raw_douban_我们爱讲冷笑话tm" "Yi-club" "0 25 75 100"
fetch_weibo_search "joke_笑话/weibo_search_#精选笑话#" "%2523%25E7%25B2%25BE%25E9%2580%2589%25E7%25AC%2591%25E8%25AF%259D%2523" "$(generate_seq 1 22)"
fetch_weibo "joke_笑话/weibo_冷笑话rmlxh" "2824339867" "1 2 3 4"
fetch_weibo "joke_笑话/weibo_热门笑话搜罗" "kenneylove" "$(generate_seq 1 33)" ## 质量不行
fetch_weibo "joke_笑话/weibo_热门笑话斋" "2368307107" "$(generate_seq 1 218)"
fetch_weibo "joke_笑话/weibo_冷笑话幽默搞笑选" "2507161702" "$(generate_seq 1 327)"
fetch_weibo "joke_笑话/weibo_魂淡是怎样练成的" "3002847684" "$(generate_seq 1 13)"
fetch_weibo_direct_user "joke_笑话/weibo_最幽默排行榜" "612072220" "$(generate_seq 1 865)"
fetch_weibo_direct_user "joke_笑话/weibo_两性内涵幽默" "siwajizhongying" "$(generate_seq 1 73)"
