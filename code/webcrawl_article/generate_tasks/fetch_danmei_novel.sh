. /usr/bin/utility_xzb.sh
. utility/fetch_post_utility.sh

fetch_haowenz "danmei_耽美微小说/haowenz" "1 2 3 4 5"
fetch_weibo "danmei_耽美微小说/weibo_glbl" "glbl" "$(generate_seq 1 304)"
fetch_weibo "danmei_耽美微小说/weibo_piaoxiangyuan" "piaoxiangyuan" "$(generate_seq 1 13)"
fetch_weibo_search "danmei_耽美微小说/weibo_search_#耽美微小说#" "%2523%25E8%2580%25BD%25E7%25BE%258E%25E5%25BE%25AE%25E5%25B0%258F%25E8%25AF%25B4%2523" "$(generate_seq 1 50)"
