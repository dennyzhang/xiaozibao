-- Initial script for mysql

-- /usr/bin/mysql -uroot -p

use xzb;

-- ############################### CREATE TABLE #############################################
CREATE TABLE if not exists users(
       userid VARCHAR(50) NOT NULL PRIMARY KEY,
       memo VARCHAR(100)
);

CREATE TABLE if not exists user_group(
       groupid VARCHAR(50) NOT NULL,
       userid VARCHAR(50) NOT NULL,
       memo VARCHAR(100),
       PRIMARY KEY(groupid, userid)
);

CREATE TABLE if not exists posts (
       id CHAR(40) NOT NULL PRIMARY KEY,
       category VARCHAR(50) NOT NULL,
       title VARCHAR(200) NOT NULL,
       memo VARCHAR(100)
);

CREATE TABLE if not exists deliver (
       userid VARCHAR(50) NOT NULL,
       category VARCHAR(50) NOT NULL,
       topic VARCHAR(50) NOT NULL,
       deliver_date DATE NOT NULL,
       id CHAR(40) NOT NULL,
       memo VARCHAR(100),
       PRIMARY KEY (userid, category, topic, deliver_date)
);

-- ###########################################################################################

-- ################################ CREATE PROCEDURE #######################################
-- create procedure
DROP PROCEDURE if exists deliver_default_post;

DELIMITER //
CREATE PROCEDURE deliver_default_post(in date varchar(255), in category varchar(255),
       in default_postid varchar(255),in topic varchar(255)
)
BEGIN
REPLACE INTO deliver(userid, category, deliver_date, id, topic)
select distinct(userid), category, date, default_postid, topic from users
where default_postid is not null;
END //
DELIMITER ;

-- create procedure
DROP PROCEDURE if exists replace_post;

DELIMITER //
CREATE PROCEDURE replace_post(in userid_v varchar(255), in category_v varchar(255),
       in deliver_date_v varchar(255), in id_v varchar(255), in topic_v varchar(255))
BEGIN
REPLACE INTO deliver(userid, category, deliver_date, id, topic) VALUES (userid_v, category_v, deliver_date_v, id_v, topic_v);
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS load_schedule_update;
DELIMITER //
CREATE PROCEDURE load_schedule_update(in userid_v varchar(255), in category_v varchar(255), in id_v varchar(255))
BEGIN
DECLARE v_max INT unsigned default 7;
DECLARE v_counter INT unsigned default 0;

  while v_counter < v_max do
    select @date := DATE_ADD(CURDATE(), INTERVAL +v_counter DAY);
    call replace_post(userid_v, category_v, @date, id_v, "");
    set v_counter=v_counter+1;
  end while;
  commit;
end //

DELIMITER ;

DROP PROCEDURE if exists add_allusers_to_group;

DELIMITER //
CREATE PROCEDURE add_allusers_to_group(in groupid_v varchar(255))
BEGIN
INSERT INTO user_group(groupid, userid) SELECT groupid_v, userid from users;
END //
DELIMITER ;
-- ###########################################################################################
-- add some sample posts
REPLACE INTO posts(id, category, title) VALUES ("3aaae1a35a73722372e1b49343c2c3dc", "idea_创意", "有 1000 万资金，该怎么去经营一个互联网创业项目？");
