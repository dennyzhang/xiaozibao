package webcrawler

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"regexp"
	"bytes"
	"html"
	"os"
	"os/exec"
	"math/rand"
	"strings"
	"strconv"
	"html/template"
)

type Stringy func(url string) Post_data

type Post_data struct {
	Title string
	Summary string
	Content string
	Source string
	Category string
}

type Action_fun func(src_string string, from_str string, end_str string) string

type Action struct {
        function Action_fun
        object string
        from_str string
        end_str string
}

func determinate_worker(url string) Stringy {
	//fmt.Println("determinate_worker:"+ url+ "\n")
        if val, ok := fetcher[url]; ok {
                return val
        }
        for k, v := range fetcher {
                if regexp.MustCompile(k).MatchString(url) == true {
			//fmt.Println("k:"+ k+ " url:" + url +"\n")
                        return v
                }
        }
        return default_webcrawler
}

func Apply_crawler(url string) Post_data {
	// TODO: matching by regexp

	// TOOD: defensive code
        url_crawler := determinate_worker(url)

        if url_crawler == nil {
                url_crawler = default_webcrawler
        }
	return url_crawler(url)
}

func AssertMatch(content_str string, regexp_str string, error_message string) string {
	if regexp.MustCompile(regexp_str).MatchString(content_str) == false {
		panic(error_message)
		return ""
	}
	return content_str
}

func Filter(content_str string, string_start string, string_end string) string {
	// TODO: defensive code
	pos_start := strings.Index(content_str, string_start)
        if pos_start == -1 {
                pos_start = 0
                fmt.Println("filter_content_string fail to get pos_start for " + string_start + "\n")
        } else {
		pos_start = pos_start + len(string_start)
	}

	pos_end := strings.LastIndex(content_str, string_end)
        if pos_end == -1 {
                pos_end = 0
                fmt.Println("filter_content_string fail to get pos_end for " + string_end + "\n")
                content_str = content_str[pos_start:]
        } else {
                content_str = content_str[pos_start:pos_end]
        }
	//fmt.Printf(content_str)
        return content_str
}

func Replace(content_str string, regexp_str string, rep_str string) string {
	return regexp.MustCompile(regexp_str).ReplaceAllString(content_str, rep_str)
}

func Webcrawler(url string) (string, string) {
	content := urlFetcher(url)

        //fmt.Printf(content)

	charset := "utf-8"
	match_strings := regexp.MustCompile(`charset=['\" ]*([^'\"]*)['\"]*`).FindAllStringSubmatch(content, -1)
	// TODO defensive code
        if len(match_strings) > 0 {
		charset = match_strings[0][1]
		if charset == "gbk" {
			charset = "gb2312"
		}
        }
	//fmt.Printf("charset: " + charset+". match_str:" + match_strings[0][1] +".\n")
	//fmt.Printf(content)

	if charset == "gb2312" {
		content = gb2312_to_utf8(content)
	}

	title := regexp.MustCompile("(?i)<title>([^<]*)</title>").FindAllStringSubmatch(content, -1)

	title_str := ""
	if len(title) > 0 {
		title_str = title[0][1]
	} else {
		fmt.Printf("Error: Webcrawler can't find title. url:" + url + "\n")
		title_str = "error_fail_get_title_" + strconv.Itoa(rand.Intn(1000)) + "_" + strconv.Itoa(os.Getpid())
	}

        content = html.UnescapeString(content)
        title_str = html.UnescapeString(title_str)
	return title_str, content
}

// ########################## private functions ###########################
 func weibo_get_url(content string) string {
    content = content[len("url="):]
    content = strings.Replace(content, "&mid", "", -1)
    content = strings.Replace(content, "\\", "", -1)
    content = "/>"+content+"<denny_stumb "
    return content
 }

func strip_html_tag(content string) string {
	// TODO temporary workaround for weibo
	content = regexp.MustCompile("url=http:[^&]+&mid").ReplaceAllStringFunc(content, weibo_get_url)
	content = regexp.MustCompile("<tr[^>]*>").ReplaceAllString(content, "\n")
	content = regexp.MustCompile("<br[^>]*/>").ReplaceAllString(content, "\n")
	content = regexp.MustCompile("</td>\n").ReplaceAllString(content, " ")
	content = regexp.MustCompile("<[^>]*>").ReplaceAllString(content, " ")
	//fmt.Print(content)
	return content
}

func common_wash_content(content string) string {
	// TODO filter: CDATA, javascript

	//content = regexp.MustCompile("<!\\[CDATA\\[[^>]*\\]\\]>").ReplaceAllString(content, "")

	//content = regexp.MustCompile("(?m)<script[^>]*>.*</script>").ReplaceAllString(content, "")

	//content = regexp.MustCompile(`(?m)<script>.*<script>`).ReplaceAllString(content, "<script></script>")

	//fmt.Printf(content)
	//content = regexp.MustCompile("<[^>]*>").ReplaceAllString(content, " ")

	content = regexp.MustCompile("\r").ReplaceAllString(content, "")
	content = regexp.MustCompile("\t*").ReplaceAllString(content, "")
	content = regexp.MustCompile(" *$").ReplaceAllString(content, "")
	content = regexp.MustCompile("\n\n+").ReplaceAllString(content, "\n\n")

	return content
}

func gb2312_to_utf8(content string) string {
	cmd := exec.Command("iconv", "-f", "gb2312", "-t", "utf-8")
	cmd.Stdin=strings.NewReader(content)
	var out bytes.Buffer
	cmd.Stdout=&out
	err:=cmd.Run()
	if(err!=nil) {
		fmt.Print(err)
		//fmt.Print(out)
		fmt.Println("gb2312_to_utf8 failed.")
		//fmt.Print(content)
	}
	//fmt.Printf("%q\n",out.String())
	return string(out.Bytes())
}

func errorHandler(err error) {
	if err != nil {
		fmt.Println(err)
	}
}

func setCookie(url string, req *http.Request ) bool {
	cookie_dir := os.Getenv("XZB_HOME") + "/code/webcrawl_article/webcrawler/cookie/"
	list := strings.Split(url, "/")
	cookie_file := cookie_dir + list[2]
        bytes, err := ioutil.ReadFile(cookie_file)
        if err == nil {
		req.Header.Set("Cookie", string(bytes))
        }
        return true
}

func urlFetcher(url string) string {
	client := &http.Client{}
	req, err := http.NewRequest("GET", url, nil)

	setCookie(url, req)

	//req.Header.Set("Cookie", "q_c0=\"NDBiMDcyYzEyYTE0ZjA5N2U4NmE3NTRjNzNlN2FlYTh8aG45U1QwM0FBcldGYXNqNw==|1360513150|122c5023e9667a713c9d34f91b104309754323a0\"") // TODO
	//req.Header.Set("Cookie", "SINAGLOBAL=3636427032761.276.1359442712353; myuid=3147708277; un=markfilebat@126.com; wvr=5; __utma=15428400.937117310.1360560189.1360560189.1360833166.2; __utmz=15428400.1360833166.2.2.utmcsr=blog.sina.com.cn|utmccn=(referral)|utmcmd=referral|utmcct=/s/blog_4dbcd2730100x75r.html; NSC_wjq_xfjcp.dpn_w3.6_w4=ffffffff0941139945525d5f4f58455e445a4a423660; SUE=es%3Def6f8f611e18146d32ea487a89f36ba6%26ev%3Dv1%26es2%3D55efd174dcc7db2ce1f2850102bc63b7%26rs0%3DPK8NMhgUZ%252BawKmRB7njxciPjIyOsdUYjtPbaK4GUT%252BJLQ7hTmJZIeke3qmNFEByuWGosubMWg7EueqXH6Iwrod3f7H%252FUESn3yzx2o%252BIh%252BljzYgLntAtGjSR8mpTyyQO2XzKRBfWQVWeNehH6tGj%252FNKFa6JdmAOssNbNIE3ldrYg%253D%26rv%3D0; SUP=cv%3D1%26bt%3D1360980703%26et%3D1361067103%26d%3Dc909%26i%3D18ce%26us%3D1%26vf%3D0%26vt%3D0%26ac%3D2%26uid%3D1686664253%26user%3Dmarkfilebat%2540126.com%26ag%3D4%26name%3Dmarkfilebat%2540126.com%26nick%3Dfilebat%26fmp%3D%26lcp%3D2012-04-07%252022%253A45%253A22; SUS=SID-1686664253-1360980703-JA-wrkx9-19fc29c467cd014d333e7f9980e9eff3; ALF=1361117866; SSOLoginState=1360980703; v=5; s_tentry=login.sina.com")

	errorHandler(err)
	resp, err := client.Do(req)

	//resp, err := http.Get(url)
	errorHandler(err)
	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	errorHandler(err)
	//fmt.Printf(string(body))
	return string(body)
}

func get_html_body(content string) string {
	//fmt.Print(content)

	// TODO: defensive code
	pos_start := strings.Index(content, "<body")
        if pos_start == -1 {
                fmt.Printf("Error filter_content fail for <body\n")
                pos_start = 0
        }
	// TODO: strart from pos_start
	pos_end := strings.LastIndex(content, "</body>")
        if pos_end == -1 {
                fmt.Printf("Error filter_content fail for </body>\n")
                content = content[pos_start:]
        } else {
                content = content[pos_start:pos_end]
        }

	return content
}

func default_webcrawler(url string) Post_data {
        // TODO: add error here
        fmt.Printf("Error: can't find webcrawler for " + url + "\n")
        return common_webcrawler(url, "unknown", []Action{})
}

func post_wash_title(title string) string {
	title = strings.Replace(title, "\n", " ", -1)
	title = strings.Replace(title, "\"", "'", -1)
	title = regexp.MustCompile("^ +").ReplaceAllString(title, "")
	title = regexp.MustCompile(" +$").ReplaceAllString(title, "")
	title = regexp.MustCompile(" +").ReplaceAllString(title, " ")
	return title
}

func post_wash_content(content string) string {
	content = regexp.MustCompile("(?m) +$").ReplaceAllString(content, "")
	content = regexp.MustCompile("(?m)\n\n+").ReplaceAllString(content, "\n\n")
	content = regexp.MustCompile("  +").ReplaceAllString(content, "  ")
	content = regexp.MustCompile(" ").ReplaceAllString(content, " ")
	return content
}

func common_webcrawler(url string, category string, actions []Action) Post_data {
        title, content := Webcrawler(url)
        content = get_html_body(content)
        content = common_wash_content(content)
	content = strip_html_tag(content)

	//fmt.Printf(content)
	
        for i := range actions {
                action := actions[i]
                if action.object == "content" {
                        content = action.function(content, action.from_str, action.end_str)
                } else {
                        title = action.function(title, action.from_str, action.end_str)
                }
        }
	title = post_wash_title(title)
	content = post_wash_content(content)
	//fmt.Print(content)
        return Post_data{title, "", content, url, category}
}

func common_webcrawler_not_strip_body(url string, category string, actions []Action) Post_data {
        title, content := Webcrawler(url)
        content = common_wash_content(content)
	content = strip_html_tag(content)

	//fmt.Printf(content)

        for i := range actions {
                action := actions[i]
                if action.object == "content" {
                        content = action.function(content, action.from_str, action.end_str)
                } else {
                        title = action.function(title, action.from_str, action.end_str)
                }
        }
	title = post_wash_title(title)
	content = post_wash_content(content)
        return Post_data{title, "", content, url, category}
}

func common_webcrawler_not_strip_body2(url string, category string, actions []Action) Post_data {
        title, content := Webcrawler(url)

	record_strings := ""
	link_pattern :=  "<em>.*<\\\\/em>"
        match_strings := regexp.MustCompile(link_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		record_strings = record_strings + "\n" +  match_strings[i][0]
        }

	content = record_strings
        content = common_wash_content(content)
	content = strip_html_tag(content)

	content = Replace(content, "http:[^ ]+", "")
	content = Replace(content, "\\\\n", "\n")
	// TODO: better way
	utf_pattern :=  "\\\\u([0-9a-z][0-9a-z][0-9a-z][0-9a-z])"
        match_strings = regexp.MustCompile(utf_pattern).FindAllStringSubmatch(content, -1)
        for i := range match_strings {
		int_t, _ := strconv.ParseUint(match_strings[i][1], 16, 0)
		content = strings.Replace(content, match_strings[i][0], string(int_t), -1)
        }
	//content = Replace(content, "\n", " ")
	content = template.HTMLEscapeString(content)
	
        for i := range actions {
                action := actions[i]
                if action.object == "content" {
                        content = action.function(content, action.from_str, action.end_str)
                } else {
                        title = action.function(title, action.from_str, action.end_str)
                }
        }
	title = post_wash_title(title)
	content = post_wash_content(content)

        return Post_data{title, "", content, url, category}
}

func common_webcrawler_test(url string, category string, actions []Action) Post_data {
        title, content := Webcrawler(url)
        content = get_html_body(content)
	//fmt.Printf(content)
        content = common_wash_content(content)
	content = strip_html_tag(content)

	//fmt.Printf(content)

        for i := range actions {
                action := actions[i]
                if action.object == "content" {
                        content = action.function(content, action.from_str, action.end_str)
                } else {
                        title = action.function(title, action.from_str, action.end_str)
                }
        }
	title = post_wash_title(title)
	content = post_wash_content(content)
        return Post_data{title, "", content, url, category}
}

func get_keyword_from_url(url_pattern string, url string) string {
        match_strings := regexp.MustCompile(url_pattern).FindAllStringSubmatch(url, -1)
	//fmt.Print(match_strings)
	return match_strings[0][1]
}

// ########################################################################
