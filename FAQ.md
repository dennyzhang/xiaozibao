xiaozibao - FAQ
=========
| Item                                   | Comment                                                                      |
|:----------------------------------------|------------------------------------------------------------------------------|
| 如何初始化本地环境 |git clone 源代码; 进入代码根目录，运行make install. （由于部分初始化逻辑不容易自动化，故将需要手动做的事情，写在代码的TODO里。具体参见make install的实现）|
|启动各服务| make start|
| 检查各服务运行是否正常| make check|
| 运行iOS客户端|  用Xcode打开code/show_article/ios_client/MasterDetail.xcworkspace; 并把MasterDetail/constants.h中的SERVERURL常量修改成本地正确值|
|将文章库load到数据库中| make update|
