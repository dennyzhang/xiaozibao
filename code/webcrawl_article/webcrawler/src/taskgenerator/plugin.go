package taskgenerator

import (
        "fmt"
        "webcrawler"
	"regexp"
)

var generator = map[string] Stringy {
	"^http://haowenz.com/a/[a-z]+/.*": haowenzcom_1,
	"^http://techcrunch.com/$": techcrunch_1,
	"^http://techcrunch.com/.*$": techcrunch_2,
	"^http://.*.stackexchange.com/.*$": stackexchange_1,
	"^http://stackoverflow.com/questions/tagged/.*$": stackoverflow_1,

	"^http://svbtle.com/$": func(url string) []Task { return generator_simple(url,
			"<a href=\"http://(.*)\" class=\"article_link\">", "http://")},

	"^http://www.chineseinla.com/today_highlight.*$": func(url string) []Task { return generator_simple(url,
			"<dt><a href=\"(http://www.chineseinla.com/f/page_viewtopic/t_[0-9]+.html)\"", "")},

	"^http://www.zreading.cn/.*$": func(url string) []Task { return generator_simple(url,
			"<a href=\"(http://www.zreading.cn/archives/[0-9]+.html)\"", "")},

	"^http://news.ycombinator.com/$": func(url string) []Task { return generator_simple(url,
			"<td class=\"title\"><a href=\"([^\"]*)\"", "")},

	"^http://www.zhihu.com/topic/[0-9]+/top-answers.*$": func(url string) []Task { return generator_simple(url,
			"<a class=\"question_link\" .*href=\"/question/([^\"]*)\"", "http://www.zhihu.com/question/")},

	"^http://www.douban.com/group/.*/discussion\\?.*$": func(url string) []Task { return generator_simple(url,
			"<a href=\"http://www.douban.com/group/topic/([0-9]+)/\"", "http://www.douban.com/group/topic/")},

	"^http://zenhabits.net/archives/$": func(url string) []Task { return generator_simple(url,
			"<a href=\"(http://zenhabits.net/[^\"]+)\">", "")},

	"^http://www.36kr.com/feed$": func(url string) []Task { return generator_simple(url,
			"<link>(http://www.36kr.com/p/[0-9]*.html)</link>", "")},

	"^http://www.geekpreneur.com/page/.*$": func(url string) []Task { return generator_simple(url,
			"<span class=\"title\"><a href=\"(http://www.geekpreneur.com/[^\"]+)\" ", "")},

	"^http://www.v2ex.com/go/.*$": func(url string) []Task { return generator_simple(url,
			"<div class=\"cell .* t_(.*)\">", "http://www.v2ex.com/t/")},

	"^http://www.careercup.com/page\\?pid=.*$": func(url string) []Task { return generator_simple(url,
			"<div class=\"votesWrapper votesWrapperQuestion\" id=\"votes([^\"]*)\"", "http://www.careercup.com/question?id=")},
}

func generator_simple(url string, link_pattern string, result_prefix string) []Task {
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)
	//fmt.Print(content)

        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
	//fmt.Print(match_strings)
        for i := range match_strings {
		record_string := match_strings[i]
		tasks = append(tasks, Task{result_prefix+record_string[1]})
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

	fmt.Print(tasks)

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

func stackoverflow_1(url string) []Task {
	//link_pattern_regexp := regexp.MustCompile("http://stackoverflow.com/questions/tagged/.*").FindAllStringSubmatch(url, -1)
	//link_pattern:=link_pattern_regexp[0][0]

	//fmt.Print(url)
	tasks := make([]Task, 0)
        _, content := webcrawler.Webcrawler(url)
	//fmt.Print(content)
        content = webcrawler.Filter(content,"Tagged Questions", "<div id=\"footer\"")
        match_strings := regexp.MustCompile("<a href=\"/questions/[0-9]+.*class=\"question-hyperlink").FindAllStringSubmatch(content, -1)
	//fmt.Print(match_strings)
        for i := range match_strings {
		record_string := match_strings[i][0]
		//fmt.Print(record_string)
                url_match_record := regexp.MustCompile("<a href=\"([^\"]*)\"").FindAllStringSubmatch(record_string, -1)
		//fmt.Print(url_match_record)
		link := "http://stackoverflow.com"+url_match_record[0][1]
		//fmt.Print("\nurl:"+link+"\n")
		tasks = append(tasks, Task{link})
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
