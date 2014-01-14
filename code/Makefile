start:
	(cd ./cmd && ./start_service.sh)

check:
	(cd ./cmd && ./health_check.sh)

test:
	(cd ./show_article/webserver && make test)
	(cd ./show_article/smarty_html && make test)
	(cd ./webcrawl_article/webcrawler && make test)

demo:
	(cd ./cmd && python ./show_demo.py)

jobs:start
	(cd ./webcrawl_article/generate_tasks && make fetch_all)

install:
	(cd ./cmd && ./installation.sh)

upgrade:
	(cd ./cmd && ./upgrade.sh)

