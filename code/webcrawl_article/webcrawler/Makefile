lmake:
	export GOPATH="${XZB_HOME}/code/webcrawl_article/webcrawler"; go build webcrawler
	export GOPATH="${XZB_HOME}/code/webcrawl_article/webcrawler"; go build taskgenerator

run:
	export GOPATH="${XZB_HOME}/code/webcrawl_article/webcrawler"; go run ./src/main.go
test:
	export GOPATH="${XZB_HOME}/code/webcrawl_article/webcrawler"
	echo "Check data in ${XZB_HOME}/webcrawler_data"
	go run ./src/main.go --fetch_url "http://techcrunch.com/mobile" --shall_generator --dst_dir "product/webcrawler_raw_techcrunch_mobile"
	go run ./src/main.go --fetch_url "http://money.stackexchange.com/questions?sort=votes" --shall_generator --dst_dir "personal_finance/money.stackexchange_com_personal_finance"

	go run ./src/main.go --fetch_url "http://money.stackexchange.com/questions/1625/best-way-to-start-investing-for-a-young-person-just-starting-their-career" --dst_dir "personal_finance/money_stackexchange_com_personal_finance"

	go run ./src/main.go --fetch_url "http://www.geekpreneur.com/tweet-about-a-client-get-sued" --dst_dir "idea_startup/geekpreneur.com"

	go run ./src/main.go --fetch_url "http://www.careercup.com/page?pid=distributed-computing-interview-questions" --shall_generator --dst_dir "cloudcomputing/careercup"

	go run ./src/main.go --fetch_url "http://www.v2ex.com/go/ideas" --shall_generator --dst_dir "product/www.v2ex.com"
	go run ./src/main.go --fetch_url "http://www.v2ex.com/t/99969#reply3" --dst_dir "product/www.v2ex.com"