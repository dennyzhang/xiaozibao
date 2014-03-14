. /usr/bin/utility_xzb.sh
. utility/fetch_post_utility.sh

fetch_page "linux/programmers.stackexchange.com" "http://programmers.stackexchange.com/questions/tagged/linux?sort=votes&pagesize=15&page=" "1 2 3 4 5 6 7 8 9 10"
fetch_page "linux/unix.stackexchange.com" "http://unix.stackexchange.com/questions/tagged/linux?sort=votes&pagesize=50&page=" "1 2 3 4 5 6 7 8 9 10"
