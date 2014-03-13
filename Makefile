start:
	(cd ./cmd && ./start_service.sh)

check:
	(cd ./cmd && ./health_check.sh)

test:
	(cd ./code/show_article/webserver && make test)
	(cd ./code/show_article/smarty_html && make test)
	(cd ./code/webcrawl_article/webcrawler && make test)

update:
	sudo xzb_update_category.sh

regenerate_feedback:
	(cd ./code/filter_article/ && python ./update_post_feedback.py ../show_article/webserver/xzb_feedback.log --clean_first)

demo:
	(cd ./cmd && ./show_demo.sh)

jobs:start
	(cd ./code/webcrawl_article/generate_tasks && make fetch_all)

install:
	(cd ./cmd && ./installation.sh)

uninstall:
	(cd ./cmd && ./uninstallation.sh)

upgrade:
	(cd ./cmd && ./upgrade.sh)

