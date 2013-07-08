xiaozibao - 小字报
=========
## Demo
| Num | Name                                   | Comment                                                                      |
|:----|----------------------------------------|------------------------------------------------------------------------------|
|   1 | Build your own magzine                 | http://denny.youwen.im/                                                      |
|   2 | Dig weibo/twitter for your taste       | http://weibo.com/xue321video                                                 |

## Installation
| Num | Name                                   | Comment                                                                      |
|:----|----------------------------------------|------------------------------------------------------------------------------|
|   1 | checkout git hub                       | https://github.com/DennyZhang/xiaozibao                                      |
|   2 | 设置环境变量                           | $XZB_HOME为github的checkout目录。将其加到类似/etc/profile或.bashrc文件里，并重启机器|
|   3 | 安装mysql                              | sudo apt-get install mysql-server mysql-client libmysqlclient-dev            |
|   4 | 安装辅助工具                           | sudo pip install markdown jinja; sudo easy_install mysql-python              |
|   5 | 安装flask                              | sudo pip install flask;                                                      |
|   6 | 安装rabbitmq相关工具                   | sudo pip install pika; sudo apt-get install rabbitmq-server                  |
|   7 | 创建mysql的db和user                    |                                                                              |
|   8 | 把python的defaultencoding设置为utf-8   | http://gpiot.com/python-set-character-encoding-to-utf-8-for-deploy-cms/      |
|  9  | 启动前台                               | cd $XZB_HOME/code/webserver; python ./server.py                        |
|  10 | 安装内部自动化工具集, 名字都以xzb_开头 | cd $XZB_HOME/code/tool;sudo make install                                     |
|  11 | 安装google go                        |                                                                              |

### 创建mysql的db和user
>  mysql -u root -p
>
>   CREATE DATABASE xzb CHARACTER SET utf8 COLLATE utf8_general_ci;
>
>   CREATE USER user_2013;
>
>   SET PASSWORD FOR user_2013 = PASSWORD("ilovechina");
>
>   GRANT ALL PRIVILEGES ON xzb.* TO "user_2013"@"localhost" IDENTIFIED BY "ilovechina";
>
>   FLUSH PRIVILEGES;
>
>   EXIT;

### 把python的defaultencoding设置为utf-8
>  http://gpiot.com/python-set-character-encoding-to-utf-8-for-deploy-cms/
>  
>  sudo vim /usr/lib/python2.7/site.py
>  
>  import sys
>
>  import os
>
>  sys.setdefaultencoding('utf-8')
>
>  python -c 'import sys; print sys.getdefaultencoding()'

## Management运维
- 内部工具

| Name                           | Comment                                      |
|:--------------------------------|----------------------------------------------|
| 添加用户                       | 添加dns二级域名, 并调用xzb_create_user.sh -h |
| 更新某个category的所有文章     | xzb_update_category.sh -h                    |
| 更新某些用户文章               | xzb_update_all_user.sh -h                    |
| 对抓取到的数据做预处理的格式化 | xzb_format_posts.sh -h                       |
| 从markdown文件生成html文件     | $XZB_HOME/code/misc/markdown_to_html.sh      |

- 常见DB操作

| Name                | Comment                                                                         |
|:---------------------|---------------------------------------------------------------------------------|
| 重新初始化db schema | /usr/bin/mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/db_schema.sql |
| 更新文章投放策略    | /usr/bin/mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql |

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
