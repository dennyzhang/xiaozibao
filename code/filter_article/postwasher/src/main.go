package main

import ("os"
	"fmt"
	"postwasher"
)

func main() {
        if len(os.Args) > 1 {
                parse_opt(os.Args[1:])
                if wash_file != "" {
                        postwasher.Do_wash_file(root_dir+wash_file)
                } else {
                        postwasher.Do_wash_dir(root_dir+wash_dir)
			fmt.Printf("\n======done======\n")
                }
        } else {
                //postwasher.Do_wash_file(root_dir+"webcrawler_data/joke_笑话/weibo_冷笑话幽默搞笑选/冷笑话幽默搞笑选的微博_http:__weibo.com_u_2507161702?page=258.data")
                //postwasher.Do_wash_file(root_dir+"webcrawler_data/joke_笑话/weibo_最幽默排行榜/最幽默排行榜的微博_http:__weibo.com_612072220?page=21.data")
                //postwasher.Do_wash_file(root_dir+"webcrawler_data/joke_笑话/weibo_魂淡是怎样练成的/魂淡是怎样练成的的微博_http:__weibo.com_u_3002847684?page=13.data")
                //postwasher.Do_wash_file(root_dir+"webcrawler_data/joke_笑话/test.data")
		//postwasher.Do_wash_file(root_dir+"data/parent_赡养父母/done/你是什么时候真的感觉父母老了，当时的记忆是怎样的？.data")
		postwasher.Do_wash_file(root_dir+"webcrawler_data/colin_weibo/BrandonSun的微博_http:__weibo.com_brandonsun?page=1.data")
		fmt.Printf("\n======done======\n")
        }
}

// ########################## global varaiable ###########################
var root_dir string = os.Getenv("XZB_HOME") + "/"
var wash_file string = ""
var wash_dir string = ""
// ########################################################################

// ########################## private functions ###########################

func parse_opt(args []string) bool {
        // go run ./src/main.go --wash_file "webcrawler_data/joke_笑话/weibo_冷笑话幽默搞笑选/冷笑话幽默搞笑选的微博_http:__weibo.com_u_2507161702?page=192.data"
        // go run ./src/main.go --wash_dir "webcrawler_data/joke_笑话/weibo_冷笑话幽默搞笑选"
	count := len(args)
	for i := 0; i<count; i++ {
                switch args[i] {
                case "--wash_file":
                        wash_file = args[i+1]
                        i = i + 1
                case "--wash_dir":
                        wash_dir = args[i+1]
                        i = i + 1
                default:
                        fmt.Printf("Error: Unknown option for " + args[i])
                }
	}
        return true
}
// ########################################################################