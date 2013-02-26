-- mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql
-- call replace_post("denny", "health", "2013-02-04", "051fd6a35ad0dc031436b1ab21e440f7", "");

use xzb;

DELETE FROM user_group;
call add_allusers_to_group("joke_笑话");
call add_allusers_to_group("parent_赡养父母");
call add_allusers_to_group("food_美食");
call add_allusers_to_group("us_美国");
call add_allusers_to_group("lifehack");
call add_allusers_to_group("child_亲子");
call add_allusers_to_group("spouse_伴侣");
call add_allusers_to_group("fun_娱乐");

INSERT INTO user_group(groupid, userid) VALUES ("danmei_耽美", "sophia");
INSERT INTO user_group(groupid, userid) VALUES ("danmei_耽美", "clare");
INSERT INTO user_group(groupid, userid) VALUES ("danmei_耽美", "grace");

DELETE FROM user_group WHERE groupid="us_美国" AND userid IN ("yao", "sjembn");