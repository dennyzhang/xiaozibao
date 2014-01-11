start:
	(cd ./cmd && ./start_service.sh)

check:
	(cd ./cmd && ./health_check.sh)

test:
	(cd ./webcrawl_article/webcrawler && make test)

jobs:start
	(cd ./webcrawl_article/generate_tasks && make fetch_all)

install:
	(cd ./cmd && ./install.sh)

upgrade:
	(cd ./cmd && ./upgrade.sh)

