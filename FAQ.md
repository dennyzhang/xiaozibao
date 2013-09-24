xiaozibao - FAQ
=========
# Limitation to be removed
- When add a new mq channel, we need to restart snake_worker.
- Configure rabbitmq-server as autostart, in different OS.
  sudo /usr/local/sbin/rabbitmq-server start &

- To start snake_worker, we need make sure hostname is localhost.
  sudo snake_workerd start

- Where is erro log of webcrawler
  /usr/local/xiaozibao/snake_worker/log

- Add a plugin for a new website
  check $XZB_HOME/code/webcrawl_article/webcrawler/README.md to add webcrawler plugin
  add shell scripts in $XZB_HOME/code/webcrawl_article/generate_tasks

  export GOPATH="$XZB_HOME/code/webcrawl_article/webcrawler"; 
  go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/list_4_4.html" --shall_generator --dst_dir "webcrawler_raw_haowenz"
  go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/2013/2608.html" --dst_dir "webcrawler_raw_haowenz"

- Where's the db file of iphone simulator
  ls "/Users/mac/Library/Application Support/iPhone Simulator/7.0/Applications/3DDF0FA1-D528-45EC-8B6B-F84E2C31FC9B/Documents/posts.db"
  sqlite3  "/Users/mac/Library/Application Support/iPhone Simulator/7.0/Applications/3DDF0FA1-D528-45EC-8B6B-F84E2C31FC9B/Documents/posts.db" "select * from posts limit 2"