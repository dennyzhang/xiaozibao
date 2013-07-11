package main

import ("os"
        "fmt"
	"strings"
        "io/ioutil"
	"taskgenerator"
        "webcrawler"
)

func test_url(url string) bool {
	tasks := []taskgenerator.Task {
		taskgenerator.Task { url},
	}
        execute_task(tasks)
	return true
}

func test_main_url(url string) bool {
        url_list := []string {
		url,
        }
	tasks := generate_task(url_list)
	fmt.Print(tasks)
	fmt.Print("\n")

	execute_task(tasks)
	return true
}

func parse_main_url(url string) bool {
        url_list := []string {
		url,
        }
	tasks := generate_task(url_list)
        for i := range tasks {
                fmt.Printf(tasks[i].Url+"\n")
        }
	return true
}

func main() {
	if len(os.Args) > 1 {
		parse_opt(os.Args[1:])
		if shall_generator == true {
			parse_main_url(fetch_url)
		} else {
			test_url(fetch_url)
                        fmt.Printf("\n======done======\n")
		}
	} else {
		//test_url("http://www.baidu.com/s?wd=南昌+天气")
                //test_url("http://weibo.com/dennyzhang001")
                //test_url("http://weibo.com/u/1991396391")
                //test_url("http://weibo.com/anferneee")
                //test_url("http://weibo.com/1670668900/zjbnolSSa")
                //test_url("http://weibo.com/choiseongho")
                //test_url("http://weibo.com/choiseongho?page=2&pre_page=1")
                //test_url("http://weibo.com/kaifulee?page=2&pre_page=1")
                test_url("http://s.weibo.com/weibo/%2523%25E8%2580%25BD%25E7%25BE%258E%25E5%25BE%25AE%25E5%25B0%258F%25E8%25AF%25B4%2523&page=1")
                //test_url("http://weibo.com/1818636183/zjsyr54mG")
                //test_url("http://www.zhihu.com/question/20303645")
                //test_main_url("http://www.douban.com/group/Gia-club/discussion?start=50&type=essence")
                //test_url("http://www.douban.com/group/topic/16279182")
                //test_url("http://tieba.baidu.com/p/1028183708")
                fmt.Printf("\n======done======\n")
	}
}

// ########################## global varaiable ###########################
var root_dir string = os.Getenv("XZB_HOME") + "/webcrawler_data/"
var dst_dir string = ""
var shall_generator bool = false
var fetch_url string = ""
var data_separator="--text follows this line--"
// ########################################################################

// ########################## private functions ###########################
func generate_task(url_list []string) []taskgenerator.Task {
        tasks := []taskgenerator.Task {}
	for i := range url_list {
                task_list_tmp := taskgenerator.Generate_task(url_list[i])
                tasks = taskgenerator.Concat_tasklist(tasks, taskgenerator.Filter_tasklist(task_list_tmp))
	}
	return tasks
}

func execute_task(tasks []taskgenerator.Task) bool {
	for i := range tasks {
		post := webcrawler.Apply_crawler(tasks[i].Url)
		store_result(post)
	}
        return true
}

func escpae_fname(fname string) string {
	fname = strings.Replace(fname, "/", "_", -1)
	return fname
}

func store_result(post webcrawler.Post_data) bool {
	dir := ""
	if dst_dir == "" {
		dir = root_dir + "/" + post.Category
	} else {
                dir = root_dir + "/" + dst_dir
	}

	fname := dir + "/" + escpae_fname(post.Title)

	os.MkdirAll(dir, 0777)
        write_data(fname+".data", post)
	return true
}

func read_file(file_path string) string {
	content := ""
        bytes, err := ioutil.ReadFile(file_path)
        if err == nil {
		content = string(bytes)
        }
	return content
}

func write_data(fname_data string, post webcrawler.Post_data) bool {
	content := "id:\n\nsource: " + post.Source + "\n\nsummary: "
        content = content + "\n\ntitle: \n\nstatus: \n\n" + data_separator + "\n" + post.Content

        if (read_file(fname_data) == content) {
		fmt.Printf("\n============ no need to update file:" + fname_data+" ===============\n")
        } else {
		fmt.Printf("\n============ write file:" + fname_data+" ===============\n")
		f_data, err := os.OpenFile(fname_data, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0777)
		if err != nil {
			panic(err)
		}
		defer f_data.Close()

		_, err = f_data.WriteString(content)
		if err != nil {
			panic(err)
		}
        }
        return true
}

func parse_opt(args []string) bool {
	// go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/list_4_4.html" --shall_generator --dst_dir "webcrawler_raw_haowenz"
	// go run ./src/main.go --fetch_url "http://haowenz.com/a/bl/2013/2608.html" --dst_dir "webcrawler_raw_haowenz"
        count := len(args)
        for i := 0; i<count; i++ {
		switch args[i] {
		case "--dst_dir":
			dst_dir = args[i+1]
			i = i + 1
		case "--fetch_url":
			fetch_url = args[i+1]
			i = i + 1
		case "--shall_generator":
			shall_generator = true
		default:
			fmt.Printf("Error: Unknown option for " + args[i])
		}
        }
	return true
}
// ########################################################################