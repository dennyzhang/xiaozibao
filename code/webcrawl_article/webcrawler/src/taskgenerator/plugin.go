package taskgenerator

import (
        "fmt"
        "webcrawler"
	"regexp"
)

var generator = map[string] Stringy {
	"^http://www.zhihu.com/topic/[0-9]+/top-answers.*$": zhihucom_1,
	"^http://www.douban.com/group/.*/discussion\\?.*$": douban_1,
	"^http://haowenz.com/a/[a-z]+/.*": haowenzcom_1,
	"^http://svbtle.com/$": svbtlecom_1,
	"^http://techcrunch.com/$": techcrunch_1,
	"^http://techcrunch.com/.*$": techcrunch_2,
	"^http://news.ycombinator.com/$": newsycombinator_1,
	"^http://.*.stackexchange.com/[^\\/]*$": stackexchange_1,
	// RSS feed
	"^http://www.36kr.com/feed$": func(url string) []Task { return generator_rss(url,
			"<link>(http://www.36kr.com/p/[0-9]*.html)</link>") },
}

func generator_rss(url string, link_pattern string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)
	//fmt.Print(content)

        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func haowenzcom_1(url string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)
        content = webcrawler.Filter(content,"当前位置", "首页")
        match_strings := regexp.MustCompile("#.*日期.*点击.*</span>").FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i][0]
		//fmt.Print(record_string)
                url_match_record := regexp.MustCompile("# <a href=\"([^\"]*)\"").FindAllStringSubmatch(record_string, -1)
		// fmt.Print("\nurl:"+url_match_record[0][1]+"\n")
		tasks = append(tasks, Task{url_match_record[0][1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func stackexchange_1(url string) []Task {
	link_pattern_regexp := regexp.MustCompile("http://.*.stackexchange.com").FindAllStringSubmatch(url, -1)
	link_pattern:=link_pattern_regexp[0][0]

	//fmt.Print(url)
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)
	//fmt.Print(content)
        content = webcrawler.Filter(content,"All Questions", "<div id=\"footer\"")
        match_strings := regexp.MustCompile("<a href=\"/questions/[0-9]+.*class=\"question-hyperlink").FindAllStringSubmatch(content, -1)
	//fmt.Print(match_strings)
        for i := range match_strings {
		record_string := match_strings[i][0]
		//fmt.Print(record_string)
                url_match_record := regexp.MustCompile("<a href=\"([^\"]*)\"").FindAllStringSubmatch(record_string, -1)
		//fmt.Print(url_match_record)
		link := link_pattern+url_match_record[0][1]
		//fmt.Print("\nurl:"+link+"\n")
		tasks = append(tasks, Task{link})
        }

	//fmt.Print(tasks)

        return tasks
}

func svbtlecom_1(url string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")

	link_pattern :=  "<a href=\"http://(.*)\" class=\"article_link\">"
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{"http://" + record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func techcrunch_1(url string) []Task {
	fmt.Print("here: " + url + "\n")
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")
        content = webcrawler.Filter(content,"posted", "Privacy Policy")

	link_pattern :=  "<h2 class=\"headline\">\n[	 ]*<a href=\"([^\"]*)\""
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func techcrunch_2(url string) []Task {
	fmt.Print("here: " + url + "\n")
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")
        content = webcrawler.Filter(content,"posted", "Privacy Policy")

	link_pattern :=  "<h2 class=\"headline\">\n[	 ]*<a href=\"([^\"]*)\""
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func newsycombinator_1(url string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")

	link_pattern :=  "<td class=\"title\"><a href=\"([^\"]*)\""
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func zhihucom_1(url string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")

	//fmt.Print(content)

	link_pattern :=  "<a class=\"question_link\" .*href=\"/question/([^\"]*)\""
	// TODO: assertion if pattern match fail
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{"http://www.zhihu.com/question/" + record_string[1]})
        }

	//fmt.Print(tasks)

        return tasks
}

func douban_1(url string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)

        content = webcrawler.Filter(content,"<body", "</body>")

	//fmt.Print(content)

	link_pattern :=  "<a href=\"http://www.douban.com/group/topic/([0-9]+)/\""
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{"http://www.douban.com/group/topic/" + record_string[1]})
        }

	fmt.Print(tasks)

        return tasks
}
