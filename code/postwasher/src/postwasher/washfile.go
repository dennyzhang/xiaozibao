package postwasher

import (
        "fmt"
	"os"
        "io/ioutil"
        "strings"
        "regexp"
)

type Post struct {
        Metadata map[string] string
        Data string
}

func parse_post(content string) Post {
        post_ret := Post{}
        content = common_wash_post(content)
        index := strings.Index(content, DATA_SEPARATOR)
        if (index == -1) {
                panic("fail to parse post")
        }
        metadata_str := content[0:index]
        post_ret.Metadata = parse_post_meta(metadata_str)

        data_str := content[index+len(DATA_SEPARATOR)+1:]
        post_ret.Data = wash_post_data(data_str)

        return post_ret
}

func Do_wash_file(file_path string) bool {
        //fmt.Printf("do_wash_file, file_path:" + file_path + "\n")
        content := read_file(file_path)
        post := parse_post(content)
	// TODO: stub code here
	post.Data = ""
	fmt.Print(post.Data)
        return true
}

func Do_wash_dir(dir_path string) bool {
	// TODO
        fmt.Printf("do_wash_dir, dir_path:" + dir_path)
        return true
}

// ########################## private functions ###########################
func common_wash_post(content string) string {
        content = regexp.MustCompile("\n\n+").ReplaceAllString(content, "\n\n")
        content = regexp.MustCompile(DATA_SEPARATOR+"\n+").ReplaceAllString(content, DATA_SEPARATOR+"\n")
        content = regexp.MustCompile("(?m)^ +").ReplaceAllString(content, "")
        content = regexp.MustCompile("(?m) +$").ReplaceAllString(content, "")
        return content
}

func parse_post_meta(metadata_str string) map[string] string {
        meta_map := map[string] string{}
        index := 0
        key := ""
        value := ""
        lines := strings.Split(metadata_str, "\n")
        for i := range lines {
                line := lines[i]
                if line != "" {
                        index = strings.Index(line, ":")
                        key = line[0:index]
                        value = strings.TrimSpace(line[index+1:])
                        if value != "" {
				//fmt.Print("\nline: " + line + " key:" + key + " value:" + value + "\n")
				meta_map[key] = value
                        }
                }
        }

        return meta_map
}

func write_file(fname_data string, content string) bool {
	f_data, err := os.OpenFile(fname_data, os.O_WRONLY | os.O_CREATE | os.O_TRUNC, 0777)
        if err != nil {
                panic(err)
        }
	defer f_data.Close()

	_, err = f_data.WriteString(content)
	if err != nil {
		panic(err)
	}

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
// ########################################################################