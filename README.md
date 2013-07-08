xiaozibao - 小字报
=========
## Demo
| Num | Name                                   | Comment                                                                      |
|:----|----------------------------------------|------------------------------------------------------------------------------|
|   1 | Build your own magzine                 | http://denny.youwen.im/                                                      |
|   2 | Dig weibo/twitter for your taste       | http://weibo.com/xue321video                                                 |

## Installation
| Name                                   | Comment                                                                      |
|:----------------------------------------|------------------------------------------------------------------------------|
| checkout git hub                       | https://github.com/DennyZhang/xiaozibao                                      |
| install mysql-server                   |                                                                              |
| install mysql client packages          | sudo apt-get install mysql-client libmysqlclient-dev            |
| install google go                      | http://blog.ec-ae.com/?p=7867#sec-1-1                                          |
| install rabbitmq                       | sudo apt-get install rabbitmq-server                                         |
| install and enforce puppet             | Follow instruction of puppet/README.md                                       |
| reboot server                          | Since puppet will update /etc/profile, we need a reboot to take effect       |
| 启动前台                                | cd $XZB_HOME/code/webserver; python ./server.py                        |

## Management运维
- 常见DB操作

| Name                | Comment                                                                         |
|:---------------------|---------------------------------------------------------------------------------|
| 重新初始化db schema | /usr/bin/mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/db_schema.sql |
| 更新文章投放策略    | /usr/bin/mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql |

- 内部工具

| Name                           | Comment                                      |
|:--------------------------------|----------------------------------------------|
| 添加用户                       | 添加dns二级域名, 并调用xzb_create_user.sh -h |
| 更新某个category的所有文章     | xzb_update_category.sh -h                    |
| 更新某些用户文章               | xzb_update_all_user.sh -h                    |
| 对抓取到的数据做预处理的格式化 | xzb_format_posts.sh -h                       |
| 从markdown文件生成html文件     | $XZB_HOME/code/misc/markdown_to_html.sh      |

- web测试

| Name           | Link                                                                       |
|:----------------|----------------------------------------------------------------------------|
| get_post       | http://127.0.0.1:8081/api_get_post?postid=ffa72494d91aeb2e1153b64ac7fb961f |
| list_user_post | http://127.0.0.1:8081/api_list_user_post?userid=denny&date=2013-01-24      |
| list_user_post | http://127.0.0.1:8081/api_list_user_post?userid=denny                      |

## Limitation
| Num | Name                                                                 | Comment                                                    |
|:-----|----------------------------------------------------------------------|------------------------------------------------------------|
|   1 | #.data头部，每一行代表则一个k:v的元数据属性                          | 该行第一个:为键值对的分隔符                                |
|   2 | #.data中meta data与data是以一行特殊的字符串来分隔                    | --text follows this line--                                 |
|   3 | 文件夹中含有_webcrawler_字符串的，表示该文件夹数据为网络爬虫抓取来的 |                                                            |
|   4 | 文件夹中含有_done_字符串的，表示该文件夹数据为已投放                 |                                                            |
|   5 | 文件夹中含有_raw_字符串的，表示该文件夹数据为未确认数据              | 调用xzb_update_category.sh,该数据的meta data不会被自动更新 |

## 数据规范
- 标题: 5字 < 长度 < 10个汉字字 (如果是英文的话，则是限额为原有基础的三倍)
- 摘要: 15字 < 长度 < 34个汉字字 (如果是英文的话，则是限额为原有基础的三倍)
- 文章: 200字 < 长度 < 2000 字
