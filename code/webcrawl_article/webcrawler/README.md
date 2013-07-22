xiaozibao - 小字报
=========
- awk -F'	' '{print $6"="$7}' ./cookies.txt

- mac start rabbitmq server
sudo /usr/local/sbin/rabbitmq-server start

- Run tasks
export GOPATH="$XZB_HOME/code/webcrawl_article/webcrawler"; 
go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/list_4_4.html" --shall_generator --dst_dir "webcrawler_raw_haowenz"
go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/2013/2608.html" --dst_dir "webcrawler_raw_haowenz"

go run ./src/main.go --fetch_url "http://techcrunch.com/mobile" --shall_generator --dst_dir "webcrawler_raw_techcrunch_mobile"
