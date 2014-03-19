package webcrawler

import (
        "fmt"
        "strings"
)

var fetcher = map[string] Stringy {
	"^http://weibo.com/u/[^/]+$": Url_weibocom_1,
	"^http://weibo.com/[^/]+$": Url_weibocom_1,
	"^http://s.weibo.com/weibo/.*$": Url_weibocom_2,
	"^http://tieba.baidu.com/p/[0-9]+$": Tieba_1,
        "^http://www.douban.com/group/topic/[0-9]+$": Url_douban_1,
        "^http://www.zhihu.com/question/[0-9]+$": Url_zhihu_1,
	"http://www.zhihu.com/question/19604574": Url_zhihu_3,
        "^http://www.quora.com/.+$": Url_quora_1,
	"^http://www.v2ex.com/t/[0-9]+.*": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "  V2EX   ", "  关于"},
			//Action {Replace, "content", "(?m)^ +[0-9]+", ""}, // TODO
		})
	},

	"^http://www.careercup.com/question\\?id=[0-9]+": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "Interview Question", " Add a Comment"},
			Action {Replace, "content", "(?m)^ +Comment hidden because of low score. Click to expand.", ""},
			Action {Replace, "content", "(?m) Reply", ""},
			Action {Replace, "content", "(?m)^ of  [0-9]+  vote", ""},
			Action {Replace, "content", "(?m)^Answers", ""},
			Action {Replace, "content", "(?m)^ Email me when people comment.", ""},
			Action {Replace, "content", "(?m)^ An error occurred in subscribing you.", ""},
			Action {Replace, "content", "(?m)^ on .*[0-9]+  Edit  \\|  Flag", ""},
			Action {Replace, "content", "(?m)^ Loading...", ""},
			Action {Replace, "content", "(?m)^ *[0-9]+", ""},
			//Action {Filter, "content", "\ns \n", "function"},
			//Action {Filter, "content", "\ns \n", "pagespeed"},
			Action {Replace, "content", "(?m)^ *s *\n", ""},
		})
	},

	"^http://zenhabits.net/.+$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "zenhabits  :  breathe", "      Posted : "},
			Action {Replace, "content", " By  ", "- "},
			Action {Replace, "content", " Post written by ", "- "},
		})
        },

	"^http://www.geekpreneur.com/.+$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "  archives", " Related posts:"},
			Action {Filter, "content", "  subscribe", "  Tweet"},
			Action {Replace, "content", "Posted by ", "- "},
			Action {Replace, "content", "(?m) +Tweet *$", ""},
			Action {Replace, "content", " ", " "},
			Action {Replace, "content", "(?m)^ !function.*", ""},
		})
        },

	"^http://www.chineseinla.com/f/page_viewtopic/t_[0-9]+.html$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "发布于:", "  返回页首"},
			Action {Replace, "content", "(?m)  返回页首", ""},
			Action {Replace, "content", "(?m)  您觉得上述讲法有帮助吗\\?", ""},
			Action {Replace, "content", "(?m)  \\[举报\\]", ""},
			Action {Replace, "content", "(?m) *[0-9]+ *$", ""},
			Action {Replace, "content", "(?m)  会陆续更新.*", ""},
		})
        },


	"^http://www.zreading.cn/archives/[0-9]+.html$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "style.backgroundColor=color\n}", "分享到："},
			Action {Filter, "content", "  \n \n \n \n \n", "/*300*250"},
			Action {Replace, "content", "(?m)\\|字体: 小 . 中 . 大.*", ""},
			Action {Replace, "content", "(?m)^  作者: ", "- "},
		})
        },

	"^http://.*stackexchange.com/questions/[0-9]+/.*": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "Tell me more", "improve this answer"},
			Action {Filter, "content", "     \n \n \n \n", "  share  |"},
			Action {Replace, "content", "\n +up vote ", ""},
			Action {Replace, "content", "\n +down vote ", ""},
			Action {Replace, "content", "\n *favorite *", ""},
			Action {Replace, "content", "(?m)^ +oldest *$", ""},
			Action {Replace, "content", "(?m)^ +votes *$", ""},
			Action {Replace, "content", "(?m)^ +answered  .*$", ""},
			Action {Replace, "content", "(?m)^ +edited  .*$", ""},
			Action {Replace, "content", "(?m)^          +.*$", ""},
			Action {Replace, "content", "(?m)^ +[0-9]+ *$", ""},
			Action {Replace, "content", "(?m)^ +show +[0-9]+ +more comment.*$", ""},
			Action {Replace, "content", " ^ +", " "},
			// Action {Filter, "content", "^", " Crunchbase"},
			Action {Replace, "content", "(?m) +$", ""},
                        Action {Replace, "content", "(?m)\n\n+", "\n"},
                        Action {Replace, "content", "(?m)$", " "},
			Action {Replace, "content", "\n +share +\\| +improve this answer +\n", "\n\n- "},
			Action {Replace, "content", "\n +share +\\| +improve this question +\n", "\n\n- "},
                        Action {Replace, "content", "  +", "  "},
			// Action {Replace, "title", "(?m)[ ]+\\|[ ]+TechCrunch$", ""},
		})
	},

	"^http://stackoverflow.com/questions/[0-9]+/.*": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "Tell me more", "improve this answer"},
			Action {Filter, "content", "     \n \n \n \n", "  share  |"},
			Action {Replace, "content", "\n +up vote ", ""},
			Action {Replace, "content", "\n +down vote ", ""},
			Action {Replace, "content", "\n *favorite *", ""},
			Action {Replace, "content", "(?m)^ +oldest *$", ""},
			Action {Replace, "content", "(?m)^ +votes *$", ""},
			Action {Replace, "content", "(?m)^ +answered  .*$", ""},
			Action {Replace, "content", "(?m)^ +edited  .*$", ""},
			Action {Replace, "content", "(?m)^          +.*$", ""},
			Action {Replace, "content", "(?m)^ +[0-9]+ *$", ""},
			Action {Replace, "content", "(?m)^ +show +[0-9]+ +more comment.*$", ""},
			Action {Replace, "content", " ^ +", " "},
			// Action {Filter, "content", "^", " Crunchbase"},
			Action {Replace, "content", "(?m) +$", ""},
                        Action {Replace, "content", "(?m)\n\n+", "\n"},
                        Action {Replace, "content", "(?m)$", " "},
			Action {Replace, "content", "\n +share +\\| +improve this answer +\n", "\n\n- "},
			Action {Replace, "content", "\n +share +\\| +improve this question +\n", "\n\n- "},
                        Action {Replace, "content", "  +", "  "},
			// Action {Replace, "title", "(?m)[ ]+\\|[ ]+TechCrunch$", ""},
		})
	},

	"^http://techcrunch.com/.+/$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "posted", "Tags: "},
			Action {Filter, "content", " Comments ", " « previous story"},
			Action {Filter, "content", "^", " Crunchbase"},
			Action {Replace, "content", "(?m) +$", ""},
                        Action {Replace, "content", "(?m)\n\n+", "\n"},
                        Action {Replace, "content", "(?m)$", " "},
			Action {Replace, "title", "(?m)[ ]+\\|[ ]+TechCrunch$", ""},
		})
        },

	"^http://haowenz.com/a/[a-z]+/$": func(url string) Post_data {
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "当前位置:微小说>耽美微小说>", "查看全篇微小说"},
			Action {Replace, "content", "\n\n+", "\n"},
			Action {Replace, "content", "查看全篇微小说", ""},
			Action {Replace, "content", "日期：............:..:..", ""},
			Action {Replace, "content", "点击：[0-9]*", ""},
			Action {Replace, "content", " #耽美微小说#", "* "},
			Action {Replace, "title", "_.*-微小说网", ""},
			Action {Replace, "title", ".*：", ""},
		})
        },
	"^http://haowenz.com/a/[a-z]+/[0-9]+/[0-9]+.*html$": func(url string) Post_data {
		//panic("err")
		return common_webcrawler(url, []Action {
			Action {Replace, "content", " *", ""},
			Action {Replace, "content", "　", " "},
			Action {Filter, "content", "当前位置", "你可能还喜欢以下"},
			Action {Replace, "content", "\n\n+", "\n"},
			Action {Replace, "content", "时间:[0-9-:]*发布:", ""},
			Action {Replace, "content", "微小说.*", ""},
			Action {Replace, "content", ".*，创建于.*", ""},
			Action {Replace, "content", " #耽美微小说#", "* "},
			Action {Replace, "content", " ", ""},
			Action {Replace, "content", "^:\n", ""},
			Action {Replace, "content", "(?m) +$", ""},
			Action {Replace, "content", "(?m)-$", ""},
			Action {Replace, "content", "(?m)^$\n", ""},
			Action {Replace, "content", "\n你可能还喜欢以下", ""},
			Action {Replace, "content", "^", "- "},
			Action {Replace, "title", "_微小说.*", ""},
			Action {Replace, "title", ".*：", ""},
		})
	},
	"^http://www.36kr.com/p/[0-9]+.html$": func(url string) Post_data {
                return common_webcrawler(url, []Action {
                        Action {Filter, "content", "E-Mail", "文章评论"},
			Action {Replace, "content", "(?m) +$", ""},
                        Action {Filter, "content", "\n\n\n\n\n", " 新浪微博"},
                        Action {Filter, "content", " ", "\n\n\n\n\n\n\n\n\n\n"},
                        Action {Replace, "title", " \\| 36氪", ""},
                        Action {Replace, "content", "\n\n\n\n\n\n\n\n\n\n", ""},
                        Action {Replace, "content", "(?m)^via Lifehacker$", ""},
                        Action {Replace, "content", "\n\n+", "\n\n"},
                        Action {Replace, "content", " 来源: .*", ""},
                        Action {Replace, "content", "^ +", ""},
                })
        },

	"^http://stock.stcn.com/sh/[0-9]+/$": func(url string) Post_data{
		keyword := get_keyword_from_url("http://stock.stcn.com/sh/([0-9]+)", url)
		return common_webcrawler(url, []Action {
			Action {Filter, "content", keyword, "净流量"},
			Action {Replace, "content", "(?m)^ +", ""},
			Action {Replace, "content", "委比.*\n\n", ""},
			Action {Replace, "content", "净流量.*", ""},
			Action {Replace, "title", "_证券时报网", ""},
			Action {Replace, "title", "\\([0-9]+\\)", " 股票"},
			Action {Replace, "content", "^", "- [股票 " + keyword + "]: \n"},
		})
	},

	"http://www.pm2d5.com/city/.*.html": func(url string) Post_data{
		keyword := get_keyword_from_url("http://www.pm2d5.com/city/(.*)\\.html", url)
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "首页", "手机请"},
			Action {Filter, "content", "各监测站点实时数据", "var caption"},
			Action {Replace, "content", "(?m)^ +", ""},
			Action {Replace, "content", "^\n", ""},
			Action {Replace, "content", "(?m)\n\n+", "\n"},
			Action {Replace, "content", "PM2.5", ""},
			Action {Replace, "content", "更新时间.*", ""},
			Action {Replace, "content", " {7}.*", ""},
                        Action {Replace, "content", "\n监测站点.*", ""},
			Action {Replace, "content", "^", "- [PM2.5 "+ keyword +"] "},
			Action {Replace, "title", "市PM2.5.*", " PM"},
		})
	},

	"^http://www.google.com/finance\\?q=[a-z]+$": func(url string) Post_data{
		keyword := get_keyword_from_url("http://www.google.com/finance\\?q=([a-z]+)", url)
		return common_webcrawler(url, []Action {
			Action {Filter, "content", "google.finance.renderRelativePerformance", "Currency in USD"},
                        Action {Replace, "content", "(?m) +$", ""},
                        Action {Replace, "content", "\\(\\);\n", ""},
			Action {Replace, "content", "\n", " "},
			Action {Replace, "content", "^ +", ""},
			Action {Replace, "content", " +", " "},
                        Action {Replace, "content", "\n\n+", "\n"},
			Action {Replace, "content", "\\).*", ")"},
                        Action {Replace, "content", "^", "- [股票] " + keyword + " "},
                        Action {Replace, "title", ":.*", ""},
		})
	},

	"http://www.baidu.com/s\\?wd=.*\\+天气": func(url string) Post_data{
		keyword := get_keyword_from_url("http://www.baidu.com/s\\?wd=(.*)\\+天气", url)
                return common_webcrawler(url, []Action {
                        Action {Filter, "content", "中国天气网", "更多城市"},
                        Action {Replace, "content", "- 最近访问：", ""},
			Action {Replace, "content", " +", " "},
                        Action {Replace, "content", " 中国气象局", ""},
                        Action {Replace, "content", "201", " \n更新时间: 201"},
                        Action {Replace, "content", "发布", ""},
                        Action {Replace, "content", "^", "- [天气 " + keyword +"]："},
                        Action {Replace, "title", "百度搜索_", ""},
                })
        },

}

func Url_zhihu_1(url string)Post_data {
        post_data := common_webcrawler(url, []Action {
                Action {Filter, "content", " 查看全部 » ", " 添加评论 "},
                Action {Replace, "content", "(?m) +$", ""},
                Action {Replace, "content", "(?m)^ +", ""},
                Action {Replace, "content", "(?m)^收起$", ""},
                Action {Replace, "content", "(?m)^添加评论$", ""},
                Action {Replace, "content", "(?m)^感谢$", ""},
		Action {Replace, "content", "&p ost=ok#last", ""},
		Action {Replace, "content", "http [a-zA-Z0-9 _:/\\.=\\?]+", ""},
                Action {Replace, "content", "(?m)^匿名用户$", ""},
                Action {Replace, "content", "(?m)^没有帮助$", ""},
                Action {Replace, "content", "(?m)^分享$", ""},
                Action {Replace, "content", "(?m)^收藏$", ""},
                Action {Replace, "content", "(?m)^[0-9]+ 条评论$", ""},
                Action {Replace, "content", "(?m)^[0-9]+ 个回答$", ""},
                Action {Replace, "content", "(?m)^按票数排序$", ""},
                Action {Replace, "content", "(?m)^邀请回答$", ""},
                Action {Replace, "content", "(?m)^按票数回答$", ""},
                Action {Replace, "content", "(?m)^[0-9]+$", ""},
                Action {Replace, "content", "(?m)^编写答案总结$", ""},
                Action {Replace, "content", "(?m)^举报$", ""},
                Action {Replace, "content", "(?m)^写补充说明$", ""},
                Action {Replace, "content", "(?m)^什么是答案总结？$", ""},
                Action {Replace, "content", "(?m)^答案总结$", ""},
                Action {Replace, "content", "(?m)^•$", ""},
                Action {Replace, "content", "(?m)^更多$", ""},
                Action {Replace, "content", " ", ""},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "(?m)^[0-9]+ 票，来自\n\n.*$", ""},
                Action {Replace, "content", "(?m)^[0-9]{4}-[0-9]{2}-[0-9]{2}", ""},
                Action {Replace, "content", "(?m)^赞同$", ""},
                Action {Replace, "content", "(?m)^反对$", ""},
                Action {Replace, "content", "(?m)\n\n+", "\n\n"},
                Action {Replace, "content", "(?m)^-", " "},
                Action {Replace, "content", "(?m)^署名-非商业使用-禁止演绎\n\n", "- "},
                Action {Replace, "content", "(?m)^.zm-item-answer\"}\">\n\n", "- "},
                Action {Replace, "title", " - 知乎", ""},
        })

        // special filter
        string_start := post_data.Title
        pos_start := strings.Index(post_data.Content, string_start)
        if pos_start == -1 {
                pos_start = 0
                fmt.Println("zhihu fail to get pos_start for " + string_start + "\n")
        }

        post_data.Content = post_data.Content[pos_start:]

        return post_data
}

func Url_douban_1(url string) Post_data {
        return common_webcrawler(url, []Action {
                Action {Filter, "content", "来自:", "(typeof Do ==="},
                Action {Replace, "content", "^.*\n[0-9 \\-:]+", ""},
                //Action {Replace, "content", "^.*\n[0-9 :]+\n\n", ""},
                //Action {Replace, "content", "http://.*$", ""},
                Action {Replace, "content", "(?m) +$", ""},
                Action {Replace, "content", "(?m)^ +", ""},
		Action {Replace, "content", "http://www.douban.co m/group/topic/[0-9 ]+/\\?start=[0-9]+", " "},
                Action {Replace, "content", "(?m)^\\[已注销\\]$", ""},
                Action {Replace, "content", "(?m)^[0-9]+人$", ""},
                Action {Replace, "content", "(?m)^喜欢$", ""},
                Action {Replace, "content", "(?m)^回应$", ""},
                Action {Replace, "content", "(?m)^删除$", ""},
                Action {Replace, "content", "(?m)^推荐$", ""},
                Action {Replace, "content", "(?m)^后页>$", ""},
                Action {Replace, "content", "(?m)^[0-9]+$", ""},
                Action {Replace, "content", "\n\n+", "\n\n"},
                Action {Replace, "content", "^\n+", ""},
                Action {Replace, "content", " +", " "},
        })
}

func Tieba_1(url string)Post_data {
	return common_webcrawler(url, []Action {
                Action {Filter, "content", " 收藏 ", " 回复"},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "(?m)^ +", ""},
                Action {Replace, "content", "\n\n+", "\n\n"},
	})
}


func Url_weibocom_2(url string) Post_data {
	return common_webcrawler_not_strip_body2(url, []Action {
                //Action {Replace, "content", "(?m)^ +转发.*", ""},
                Action {Replace, "content", "(?m)^ +收藏.*", ""},
                Action {Replace, "content", "(?m)^ +评论.*", ""},
                Action {Replace, "content", "(?m)^.* {2}来自 .*", ""},
                Action {Replace, "content", "(?m) +$", ""},
                Action {Replace, "content", "(?m)^ +", ""},
                Action {Replace, "content", "(?m)\n\n+", "\n\n"},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "(?m)^", "- "},
                Action {Replace, "content", "(?m)^- $", ""},
                Action {Replace, "content", "^\n+", ""},
                Action {Replace, "title", " 新浪微博-随时随地分享身边的新鲜事儿", ""},
		Action {Replace, "title", "$", "_"+url},
	})
}

func Url_weibocom_1(url string)Post_data {
	return common_webcrawler_not_strip_body(url, []Action {
                Action {AssertMatch, "title", "新浪微博-随时随地分享身边的新鲜事儿", "weibo访问失败，请确认是否cookie需要更新"},
                Action {Filter, "content", " 更多标签 ", "我们之间的共同关系"},
                Action {Replace, "content", "\\\\n", ""},
                Action {Replace, "content", "\\\\t", ""},
                Action {Replace, "content", "\\|  举报 ", "举报\n\n"},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "(?m)^ +", ""},
                //Action {Replace, "content", "(?m) \\| 转发.*", ""},
                Action {Replace, "content", "(?m).* 关注了 @.*", ""},
                Action {Replace, "content", "(?m).*抱歉，此微博.*", ""},
                //Action {Replace, "content", "(?m)^转发微博。", ""},
                Action {Replace, "content", "(?m)^@[^：]+：", ""},
                Action {Replace, "content", "◆ ◆", ""},
                Action {Replace, "content", "(?m)^[0-9]+ ", ""},
                Action {Replace, "content", "(?m)^#", " "},
                Action {Filter, "content", "» 收回 ", "正在加载中，请稍候"},
                Action {Replace, "content", "(?m)^", "- "},
                Action {Replace, "content", "(?m)- $", ""},
                Action {Replace, "content", "(?m)-$", ""},
                Action {Replace, "content", " « ", " "},
                //Action {Replace, "content", ".* http:.*", ""},
                //Action {Replace, "content", "(?m)\\([0-9]+\\)$", ""},
                Action {Replace, "content", "(?m)^ - STK &&.*微关系$", ""},
                Action {Replace, "content", "\n\n+", "\n\n"},
                Action {Replace, "title", " 新浪微博-随时随地分享身边的新鲜事儿", ""},
		Action {Replace, "title", "$", "_"+url},
	})
}

func Url_zhihu_3(url string)Post_data {
        post_data := common_webcrawler(url, []Action {
                Action {Filter, "content", " 查看全部 » ", " 添加评论 "},
                Action {Replace, "content", "(?m) +$", ""},
                Action {Replace, "content", "(?m)^ +", ""},
                Action {Replace, "content", "(?m)^收起$", ""},
                Action {Replace, "content", "(?m)^添加评论$", ""},
                Action {Replace, "content", "(?m)^感谢$", ""},
		Action {Replace, "content", "&p ost=ok#last", ""},
		Action {Replace, "content", "http [a-zA-Z0-9 _:/\\.=\\?]+", ""},
                Action {Replace, "content", "(?m)^匿名用户$", ""},
                Action {Replace, "content", "(?m)^没有帮助$", ""},
                Action {Replace, "content", "(?m)^分享$", ""},
                Action {Replace, "content", "(?m)^收藏$", ""},
                Action {Replace, "content", "(?m)^[0-9]+ 条评论$", ""},
                Action {Replace, "content", "(?m)^[0-9]+ 个回答$", ""},
                Action {Replace, "content", "(?m)^按票数排序$", ""},
                Action {Replace, "content", "(?m)^邀请回答$", ""},
                Action {Replace, "content", "(?m)^按票数回答$", ""},
                Action {Replace, "content", "(?m)^[0-9]+$", ""},
                Action {Replace, "content", "(?m)^编写答案总结$", ""},
                Action {Replace, "content", "(?m)^举报$", ""},
                Action {Replace, "content", "(?m)^写补充说明$", ""},
                Action {Replace, "content", "(?m)^什么是答案总结？$", ""},
                Action {Replace, "content", "(?m)^答案总结$", ""},
                Action {Replace, "content", "(?m)^•$", ""},
                Action {Replace, "content", "(?m)^更多$", ""},
                Action {Replace, "content", " ", ""},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "(?m)^[0-9]+ 票，来自\n\n.*$", ""},
                Action {Replace, "content", "(?m)^[0-9]{4}-[0-9]{2}-[0-9]{2}", ""},
                Action {Replace, "content", "(?m)^赞同$", ""},
                Action {Replace, "content", "(?m)^反对$", ""},
                Action {Replace, "content", "(?m)\n\n+", "\n\n"},
                Action {Replace, "content", "(?m)^署名-非商业使用-禁止演绎\n\n", "- "},
                Action {Replace, "content", "(?m)^.zm-item-answer\"}\">\n\n", "- "},
                Action {Replace, "title", " - 知乎", ""},
        })

        // special filter
        string_start := post_data.Title
        pos_start := strings.Index(post_data.Content, string_start)
        if pos_start == -1 {
                pos_start = 0
                fmt.Println("zhihu fail to get pos_start for " + string_start + "\n")
        }

        post_data.Content = post_data.Content[pos_start:]

        return post_data
}


func Url_quora_1(url string)Post_data {
        post_data := common_webcrawler_test(url, []Action {
                Action {Filter, "content", " Add Question", " About "},
                Action {Replace, "content", "•   Embed   •", "\n\n"},
                Action {Replace, "content", " ", ""},
                Action {Replace, "content", " +", " "},
                Action {Replace, "content", "Add your answer", "\n\n"},
		Action {Replace, "content", "Answer Later Save Draft Add Answer", "\n-"},
                Action {Replace, "content", "(?m) Thank • ", "- Thank • "},
                Action {Replace, "content", "\\(more\\) Loading\\.\\.\\. [0-9]+ ", "\n"},
                Action {Replace, "content", "- Thank • .*Loading\\.\\.\\. More", ""},
		Action {Replace, "content", "Embed Quote Suggest Edits Loading\\.\\.\\. .*\n", "\n"},
		Action {Replace, "content", "Close Update Link to Questions.*", ""},
                Action {Replace, "content", "(?m) +$", ""},
                Action {Replace, "content", "(?m)^ +", ""},
                Action {Replace, "content", "(?m)^\\.\\.\\.$", ""},
                Action {Replace, "content", "\n\n+", "\n\n"},
                Action {Replace, "content", "^.*Edit Loading\\.\\.\\. ", ""},
                Action {Replace, "content", " Edit .*\n", "\n"},
                Action {Replace, "content", " [0-9]+ vote[s]* by.* [0-9]+ ", "\n"},
                Action {Replace, "content", "(?m)^- Thank • [0-9]+ [^ ]+", "-"},
                Action {Replace, "content", "(?m)^- 20[0-9]{2} ", "- "},
                Action {Replace, "title", " - Quora\\.data", ""},
        })
        return post_data
}
