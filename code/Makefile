start:
	(cd ./cmd && ./start_service.sh)
install:
	echo "TODO install"
upgrade:
	echo "TODO upgrade"

check:
	(cd ./cmd && ./health_check.sh)

jobs:start
	(cd ./webcrawl_article/generate_tasks && make fetch_all)

test:test_webcrawler

test_webcrawler:
	(cd ./webcrawl_article/webcrawler && make test)
