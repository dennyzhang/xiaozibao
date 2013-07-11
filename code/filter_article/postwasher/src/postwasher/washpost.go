package postwasher

import (
        "strings"
        "fmt"
        "strconv"
        "unicode/utf8"
        "regexp"
)

func wash_post_data(data_str string) string {
	// TODO
        //str := wash_joke(data_str)
        str := wash_weibo_god_reply(data_str)
	return str
}

type Entry struct {
        Str string
        Original_str string
        Score float64
	Forward_list []string
}

var punctuation_list []string = []string{
        ",", "，", ".", "。", ";", "；",
        "!", "！", "?", "？", "”", "“",
        "<", "《", ">", "》", "\\", "、", "`",
	":", "：", "(", "（", ")", "）",
	"{", "}", "~", "～", "/", "／",
	"°", "%", "％", "^", "……", "*", "_", "＿",
	"+", "＋", "=", "＝", "-", "－", "&", "＆",
        "←", "→",
}

// TODO
var interjection_list []string = []string{
        "据说", "转发微博", "转发", "转走", "转一转", "「转」", "(转）",
	"呜呜", "哈哈", "笑死",
        " 关注了 ", "听说 ", "逆天了", "你个吃货",
        "吗", "喔", "吧", "呢", "呜", "啊",
        "嗯", "哎", "噢", "擦 ", "神一般",
        "不错", "看一次笑一次", "霸气", "收藏",
	"彻底", "OMG", "有木有", "hold不住", "激动哇",
        "尼玛", "好欢乐", "穿越", "太NB了", "次奥",
        "肿么了", "主淫",
}

// TODO
var blacklist []string = []string{
	"分享购买", "爱美的MM",
        "元芳 你怎么看", "笑喷",
	"求好心人扩散", "获得链接",
        "链接在评论", "泪奔了", "推荐关注", " 关注我 ",
	"观注神回复", "发现神回复_Denny",
        "http:\\\\/\\\\/",
        //" http ",
}

func get_real_len(Str string) int {
	Str_trimed := strings.Replace(Str, " ", "", -1)
        return utf8.RuneCountInString(Str_trimed)
}

func print_entry(entry Entry) bool {
        if entry.Score != 0.0 {
		fmt.Print("- ", entry.Original_str, "\n\n")
		//fmt.Print("Forward_list: ", len(entry.Forward_list), " data: ", entry.Forward_list, "\n\n")
        }

        // if entry.Score != 0.0 {
	// fmt.Print("score: ", entry.Score, " real len: " + strconv.Itoa(get_real_len(entry.Str)))
	// fmt.Print(" old len: " + strconv.Itoa(len(entry.Original_str)) + "\n")
	// fmt.Print(entry.Str + "\n\n")
        // }
        // } else {
	// fmt.Print("\n#################striped###########\n")
	// fmt.Print(entry.Str + "\n")
	// fmt.Print(entry.Original_str + "\n")
	// fmt.Print("\n###################################\n")
	// }
        return true
}

func common_wash(content string) string {
	//content = regexp.MustCompile("\n").ReplaceAllString(content, " ")
	content = regexp.MustCompile("【[^】]*】").ReplaceAllString(content, " ")
	content = regexp.MustCompile("@[^@ ]* ").ReplaceAllString(content, " ")
	content = regexp.MustCompile("@[^@ ]*$").ReplaceAllString(content, " ")
	content = regexp.MustCompile("#[^#]*#").ReplaceAllString(content, " ")
	content = regexp.MustCompile(" +").ReplaceAllString(content, " ")
	content = regexp.MustCompile("[0-9 ]+$").ReplaceAllString(content, " ")
	content = regexp.MustCompile("^ +").ReplaceAllString(content, "")
	content = regexp.MustCompile(" +$").ReplaceAllString(content, "")
        return content
}

func strip_meaningless_content(content string) string {
        for i:= range punctuation_list {
                content = strings.Replace(content, punctuation_list[i], " ", -1)
        }

        for i:= range interjection_list {
                content = strings.Replace(content, interjection_list[i], " ", -1)
        }

        content = common_wash(content)

        return content
}

func enforce_blacklist(content string) bool {
        //fmt.Print("\n======"+content+"=========\n")
	for i:= range blacklist {
		block_rule := blacklist[i]
		if regexp.MustCompile(block_rule).MatchString(content) == true {
			return false
		}
	}
	return true
}


// ########################## dynamic private functions #################
func export_joke(entries []Entry, dir_path string, filename_prefix string) bool {
        record_per_file := 10
        count := 0
        content := ""
        filename := ""

        for i:= range entries {
                entry := entries[i]
                if entry.Score != 0.0 {
                        content = content + "- " + entry.Original_str + "\n\n"
                        count = count + 1
                        if (count >= record_per_file) {
                                filename = dir_path + filename_prefix + "_" + strconv.Itoa(i) + ".data"
                                // content = "id:\n\nsource: http://weibo.com/612072220\n\nsummary:\n\ntitle: weibo精选笑话\n\nstatus: prepare\n\n--text follows this line--\n" + content
                                write_file(filename, content)
                                count = 0
                                content = ""
                        }
                }
        }
        return true
}

func score_entry_blacklist(entry Entry) Entry {
	if enforce_blacklist(entry.Str) == false {
                entry.Score = 0.0
	}
        return entry
}

func score_entry_weibo_hot(entry Entry) Entry {
	if regexp.MustCompile("转发\\([0-9][0-9][0-9]").MatchString(entry.Original_str) == false {	
		entry.Score = 0.0
	}
        return entry
}

func score_entry_forwardlist(entry Entry) Entry {
	// make sure the post is hot enough
	MIN_FORWARD_LIST := 4
	if len(entry.Forward_list) < MIN_FORWARD_LIST {
                entry.Score = 0.0
	}
	entry = score_entry_forwardlist_repetition(entry)
        return entry
}

func score_entry_forwardlist_repetition(entry Entry) Entry {
	// make sure forward list have repetitions
	MIN_FORWARD_REPEITION_LENGTH := 15
	for i, forward1 := range entry.Forward_list {
		// skip too lengthy forward comment
		if (len(forward1) > 0  && (len(forward1) < MIN_FORWARD_REPEITION_LENGTH)) {
			for j, forward2 := range entry.Forward_list {
				if (forward1 == forward2 && i != j) {
					//fmt.Print(entry.Forward_list, "\n", "forward1:", forward1, ".\n", forward2, ".\n\\n")
					return entry
				}
			}
		}
	}
	entry.Score = 0.0
	return entry
}

func score_entry(entry Entry) Entry {
        // TODO: tough
        real_len := get_real_len(entry.Str)
        if real_len < MIN_ENTRY_LENGTH {
                entry.Score = 0.0
        }

        if real_len > GOOD_MAX_ENTRY_LENGTH {
                entry.Score = entry.Score * 0.9
        }

        if real_len < GOOD_MIN_ENTRY_LENGTH {
                entry.Score = entry.Score * 0.8
        }
        return entry
}


func parse_weibo_forward_list(entry Entry) Entry {
	entry.Forward_list = strings.Split(entry.Original_str, "\\/\\/")
	for i, str := range entry.Forward_list {
		entry.Forward_list[i] = strip_meaningless_content(str)
	}
	return entry
}

func wash_joke(data_str string) string {
        lines := strings.Split(data_str, "\n\n- ")
        entries := make([]Entry, len(lines))
        for i:= range lines {
                line := lines[i]
                entry := Entry{line, line, 100, []string{}}
		entry = score_entry_blacklist(entry)
                entry.Str = strip_meaningless_content(entry.Str)
                entry = score_entry(entry)
                entries[i] = entry
        }

        for i:= range entries {
                print_entry(entries[i])
        }
        //export_joke(entries, "/home/denny/backup/essential/Dropbox/private_data/xiaozibao/webcrawler_data/joke_笑话/", "最幽默排行榜的微博_http:__weibo.com_612072220_")
        //fmt.Print(entries)

        return data_str
}

func wash_weibo_god_reply(data_str string) string {
        lines := strings.Split(data_str, "\n\n- ")
        entries := make([]Entry, len(lines))
        for i:= range lines {
                line := lines[i]
                entry := Entry{line, line, 100, []string{}}
		entry = score_entry_blacklist(entry)
                entry.Str = strip_meaningless_content(entry.Str)
                entry = score_entry(entry)
		entry = parse_weibo_forward_list(entry)
		entry = score_entry_forwardlist(entry)
		entry = score_entry_weibo_hot(entry)
                entries[i] = entry
        }

        for i:= range entries {
                print_entry(entries[i])
        }
        //export_joke(entries, "/home/denny/backup/essential/Dropbox/private_data/xiaozibao/webcrawler_data/joke_笑话/", "最幽默排行榜的微博_http:__weibo.com_612072220_")
        //fmt.Print(entries)

        return data_str
}

// ######################################################################