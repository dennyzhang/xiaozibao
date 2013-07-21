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
       num int primary key AUTO_INCREMENT,
       id CHAR(40) NOT NULL unique,
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
REPLACE INTO posts(id, category, title) VALUES ("1d959bd2e61b53f3b4dfb1386ffc6606", "idea_创意", "100 平米以内的互联网初创公司的办公室，布置（不同人员的桌椅方向，位置等等）应如何考虑？可以在哪里找到好的案例参考？");
REPLACE INTO posts(id, category, title) VALUES ("4ab7015a83eeb96f7dd19597f0600561", "idea_创意", "36 氪上的文章说「应届毕业生去科技巨头公司只是维护老代码，而不是写新代码，知识增长率比创业公司要低得多」的观点正确吗？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("0523bd81301eff793e20f954cc610483", "idea_创意", "Facebook 上市，对中国创业者有哪些启示？");
REPLACE INTO posts(id, category, title) VALUES ("6a116d3c4a084d8cf5f92ed2b7ec0b0c", "idea_创意", "Facebook 刚刚准备上市，对于应届毕业生来说，此时加入是一个合适的时机吗？");
REPLACE INTO posts(id, category, title) VALUES ("74ae51bea6a4b057cfccc4c2b73abd07", "idea_创意", "Twitter 成长快吗？这个创业团队内部有什么问题？");
REPLACE INTO posts(id, category, title) VALUES ("ec154611a018f01a5bfb5c58bcaab5f2", "idea_创意", "VC 从业者是怎样完善自己的知识结构的？");
REPLACE INTO posts(id, category, title) VALUES ("9b30e4b2ef2725d4f5a8947e68de5635", "idea_创意", "VC 最爱问的问题：你这个创业项目，如果腾讯跟进了，而且几乎是产品上完全复制，你会怎么办？");
REPLACE INTO posts(id, category, title) VALUES ("b53a643c2c48a9d3ceee8d101c338ba3", "idea_创意", "VIE 结构是什么？建立的过程中需要注意什么问题？");
REPLACE INTO posts(id, category, title) VALUES ("d56fbcf80d8d26bb1cae0b488385f32c", "idea_创意", "“霜叶” 能否全面曝光所制定的糗事百科发展规划？");
REPLACE INTO posts(id, category, title) VALUES ("ae00277c154e3726296a396ff29ad1a8", "idea_创意", "「2 元店」是怎么生存的？");
REPLACE INTO posts(id, category, title) VALUES ("061cc6c90f90830810cdd1bb27005edf", "idea_创意", "「企业家精神」是什么？");
REPLACE INTO posts(id, category, title) VALUES ("e5c29b92b092bd6f2a16a400f5e5cd9b", "idea_创意", "「迅雷 CEO 邹胜龙亲自指明要做的项目，基本都以失败告终」这个说法属实吗？为什么会这样？");
REPLACE INTO posts(id, category, title) VALUES ("5df3a612b01d0dce2ce817ad395e164e", "idea_创意", "一个人做淘宝店需要多少技能？");
REPLACE INTO posts(id, category, title) VALUES ("bed360ca313b63046359b862c9b88508", "idea_创意", "一个仅缺少技术的创业团队，是否应找天使来起步项目？");
REPLACE INTO posts(id, category, title) VALUES ("fb6750fbe808a0710e6b7edd3285dfde", "idea_创意", "一个优秀的 CEO 的人际观是怎样的？");
REPLACE INTO posts(id, category, title) VALUES ("a326701b4350fb8e1a10578619a94512", "idea_创意", "一个新网站第一批用户都是怎么导入的，有哪些花钱和不花钱的引流方法？");
REPLACE INTO posts(id, category, title) VALUES ("b7a816c69d9d275baacfa8ca9d2f9ab7", "idea_创意", "一个有创业经验的人带领几个没有工作经验的朋友一起创业，工作过程当中如何协调彼此关系，如何引导大家往目标迈进？");
REPLACE INTO posts(id, category, title) VALUES ("d0eeed68b922e2d263f7de3ebeb09115", "idea_创意", "一家公司的「估值」是怎么估出来的？谁来估？");
REPLACE INTO posts(id, category, title) VALUES ("a41cf1c08528665e55bce0aa49134d10", "idea_创意", "上海有哪些优秀的互联网创业公司？");
REPLACE INTO posts(id, category, title) VALUES ("0d9ada7b9a07291d102f0f31ffcc143f", "idea_创意", "下一个互联网的热潮会出现在哪个领域？");
REPLACE INTO posts(id, category, title) VALUES ("d46e74dcb4c20dcc20d284548afffd38", "idea_创意", "个人开公司的流程是怎么样的？公司每月需要缴纳哪些税费？");
REPLACE INTO posts(id, category, title) VALUES ("43d8b2458ffed67b709f7a9baf56ee8f", "idea_创意", "中国互联网创业公司应该向豆瓣学习什么？");
REPLACE INTO posts(id, category, title) VALUES ("892095a01d783ef604513f39d03c9907", "idea_创意", "中国创业公司里最好的 CTO 都有谁？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("ddc47bc68a1cba0e029499aabe2caebf", "idea_创意", "中国版的创业工具包应该包含哪些工具？");
REPLACE INTO posts(id, category, title) VALUES ("11cb7da7c35a34469159b783bbca2796", "idea_创意", "为什么 TechCrunch 会和动点科技合作？");
REPLACE INTO posts(id, category, title) VALUES ("7a8be90bf734ea56ddb47a101bcb340a", "idea_创意", "为什么中国互联网从业者创新很少、山寨很多，达不到美国那种高度？");
REPLACE INTO posts(id, category, title) VALUES ("5130266420337dcaacafd2fbfb4ff343", "idea_创意", "为什么外卖网站很难做大？外卖网站有前途吗？");
REPLACE INTO posts(id, category, title) VALUES ("73c116a99fd3bde9a51120147ce4921c", "idea_创意", "为什么很多人都想开咖啡店、书吧？有技术门槛吗？盈利前景如何？");
REPLACE INTO posts(id, category, title) VALUES ("302c2ee1fe10244600e35d9a377efa3f", "idea_创意", "为什么很多大学生毕业后都说大学所学知识无用？");
REPLACE INTO posts(id, category, title) VALUES ("c8784f238f48606b50a7fb43d7a801a8", "idea_创意", "为什么罗永浩称锤子估值 4 亿 7000 万元？");
REPLACE INTO posts(id, category, title) VALUES ("e9d0e797926fb0189781316130b24aee", "idea_创意", "为什么饭否网值得投资？");
REPLACE INTO posts(id, category, title) VALUES ("eac91db067e06897b9d4e0af0ed973cd", "idea_创意", "互联网创业公司最常见的失败原因有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("2b58308bccd2b0bbfd3a1db4aab14e50", "idea_创意", "互联网创业初期，产品研发团队组建的预算都有哪些？分别是多少啊？");
REPLACE INTO posts(id, category, title) VALUES ("8a3c139b5068414c411b1d07be1c33d9", "idea_创意", "互联网发展了十几年，作为从业者，你错失了哪些职业和创业机会？");
REPLACE INTO posts(id, category, title) VALUES ("e349c1e58d7198758bbdf4e50d6e1970", "idea_创意", "互联网的闭环到底是什么？");
REPLACE INTO posts(id, category, title) VALUES ("f8a48b69cc7feef7a0eb0f428b59f758", "idea_创意", "互联网领域「Ideas」真的不值钱么？");
REPLACE INTO posts(id, category, title) VALUES ("dcf14627f8217785fbb5ae086164e8b7", "idea_创意", "产品死了，如何安葬？");
REPLACE INTO posts(id, category, title) VALUES ("db5d02927a080e560f269d4134a624af", "idea_创意", "产品经理（尤其是创业的）需要懂技术吗？懂到什么程度？");
REPLACE INTO posts(id, category, title) VALUES ("cf5517dc04ce7de473e5695a2f814b45", "idea_创意", "从 1998 年至今，互联网行业都有哪些观念上的变化？");
REPLACE INTO posts(id, category, title) VALUES ("7a6bd47bc4b2e9663a726186423aee73", "idea_创意", "从玩星际争霸中我们得到了什么启发？");
REPLACE INTO posts(id, category, title) VALUES ("919c9dbb13ed97aa1939c20ba38723b1", "idea_创意", "从零开始经营一家煎饼果子摊需要怎么做？");
REPLACE INTO posts(id, category, title) VALUES ("3f99819271f353ddd4d81ffe01a36187", "idea_创意", "从风投那里得到了 $100W 的种子期投资且已到账，我该如何组建公司及团队？");
REPLACE INTO posts(id, category, title) VALUES ("49895b1bfeae9b4b14bdc41010367a5e", "idea_创意", "作为创业者出身的投资人，你的投资理念是什么？被投资企业有哪些值得学习的共性？");
REPLACE INTO posts(id, category, title) VALUES ("5268aac6da3ae70198e7350d21ad52c7", "idea_创意", "作为连续创办三家上市公司的创业者，可以说季琦是现在中国最优秀的创业者吗？");
REPLACE INTO posts(id, category, title) VALUES ("ad40076f1840e18fee5d4944dd8a169d", "idea_创意", "你为什么要创业？");
REPLACE INTO posts(id, category, title) VALUES ("807c44f8b4e0220347ce77cb4743c5a2", "idea_创意", "你从《打造 Facebook》一书中学到了什么？");
REPLACE INTO posts(id, category, title) VALUES ("580baddd3e49184865bdeed86c0ba4c5", "idea_创意", "你从创业失败或犯错的经历中，得到的教训和经验是什么？");
REPLACE INTO posts(id, category, title) VALUES ("2c7c5945a57db28ffd911561f159dcd3", "idea_创意", "你的第一桶金是如何赚到的？");
REPLACE INTO posts(id, category, title) VALUES ("0d54dc57bf43981f13f38ca2e984edc3", "idea_创意", "俄罗斯 Digital Sky Technologies（DST）是怎样的一家投资公司？其创始人尤里·米尔纳（Yuri Milner）的投资风格是怎样的？");
REPLACE INTO posts(id, category, title) VALUES ("3cafb1017b5a5b8cb7284fc8332b354f", "idea_创意", "信托公司的运作方式是怎样的？投资项目同信托公司之间是什么关系？");
REPLACE INTO posts(id, category, title) VALUES ("594821c259ea2877225770b378a8f105", "idea_创意", "假如没有钱，该如何创业？");
REPLACE INTO posts(id, category, title) VALUES ("57d9f99d641cbdf03c4d0eb161fb974b", "idea_创意", "做 B2C 小公司的运营管理者（核心人员）需要慢慢培养哪些方面的能力？");
REPLACE INTO posts(id, category, title) VALUES ("3bd6fafe612ddfdcf37b4046a2540130", "idea_创意", "做一个家政服务公司的困难在哪？");
REPLACE INTO posts(id, category, title) VALUES ("7ee745ef6c00b85413a5b95db1aca63a", "idea_创意", "做生意好还是考公务员好？");
REPLACE INTO posts(id, category, title) VALUES ("8dfe2c460ec7d10f48fbe538d9141318", "idea_创意", "像 Doit.im 这样之前的功能先免费后收费的模式是否合适？有没有更好的盈利方式？");
REPLACE INTO posts(id, category, title) VALUES ("c2fed011f203bc7affe190c20f1efee9", "idea_创意", "先搞定好的婚姻再搞定好的事业，还是反之？");
REPLACE INTO posts(id, category, title) VALUES ("c6f6d9fa2ecffc215ec8abcad0485ac9", "idea_创意", "公司史上，有哪些可称得上基业长青的公司？它们普遍具备哪些特质？");
REPLACE INTO posts(id, category, title) VALUES ("1b188cbcc2242128b063944441054426", "idea_创意", "公司处于初创，几个项目的核心程序员由于薪资待遇问题准备离开，如何化解危机？");
REPLACE INTO posts(id, category, title) VALUES ("70c52e819f622b8bad8721cbea60f883", "idea_创意", "关于马化腾，有哪些有趣的故事？");
REPLACE INTO posts(id, category, title) VALUES ("4132246b540e1e2447196fd9a5a563b5", "idea_创意", "几个朋友合伙创业，如何分配股权？");
REPLACE INTO posts(id, category, title) VALUES ("4859a4500f11d1848b42b2d296670055", "idea_创意", "创业公司 CEO 如何辞退一个不合适的人？");
REPLACE INTO posts(id, category, title) VALUES ("c6d2aefec36d54073a463c3e5f9df926", "idea_创意", "创业公司 CEO 最重要的事有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("079b196914afd0a3be367082a677c4b8", "idea_创意", "创业公司、创业团队的常见元素或标签是什么？");
REPLACE INTO posts(id, category, title) VALUES ("6930cd61f70a63a6c949d033d468d958", "idea_创意", "创业公司如何保护商业秘密？");
REPLACE INTO posts(id, category, title) VALUES ("a3dde39f0b54784f987dfc3fab77d94f", "idea_创意", "创业公司如何最有效的分配期权？");
REPLACE INTO posts(id, category, title) VALUES ("ad65676e3fc3266dfa40044656ce4fe0", "idea_创意", "创业公司如何确认用户需求？");
REPLACE INTO posts(id, category, title) VALUES ("99d874fd8e31248cec3667270532b2d5", "idea_创意", "创业公司工作时间是否应该是7(天)*(14)小时？");
REPLACE INTO posts(id, category, title) VALUES ("40a964508b6901639d90ab320e575349", "idea_创意", "创业公司应该“从严治军”还是“以德服人”？");
REPLACE INTO posts(id, category, title) VALUES ("b1fa3a4c8c1db0ff4c9879cdc7bbe5c1", "idea_创意", "创业公司应该如何开会？");
REPLACE INTO posts(id, category, title) VALUES ("0d4932c1b736ef74e7a841275b60c047", "idea_创意", "创业公司应该如何招人？");
REPLACE INTO posts(id, category, title) VALUES ("207a9831af61ed9a6db3c3db3a5f3c95", "idea_创意", "创业公司怎样让新员工觉得是有前途的？");
REPLACE INTO posts(id, category, title) VALUES ("d8eb9c0adc0d97994a112288c2fa28d2", "idea_创意", "创业公司没有大公司的安全感、各种福利待遇，怎么激发大家热情把活干好？需要建立什么样的激励机制等？");
REPLACE INTO posts(id, category, title) VALUES ("80d32ed025ae37459bdc859733ab92c7", "idea_创意", "创业公司用什么方法和腾讯竞争？");
REPLACE INTO posts(id, category, title) VALUES ("e48219b8aa4eea6331e572fb5ca21116", "idea_创意", "创业公司的员工，聚会时被人问到「你们最近怎么样」时怎样回答比较好？");
REPLACE INTO posts(id, category, title) VALUES ("89015a02f927400876f1245bb94fbf47", "idea_创意", "创业团队发展了几个月之后，创始人之间的缺点逐渐暴露出来，彼此之间经常出现意见分歧，如何解决？");
REPLACE INTO posts(id, category, title) VALUES ("2863afbe1d829d4be04f6a52b2fd6089", "idea_创意", "创业团队如何与兼职做饭的阿姨结算工资比较好？");
REPLACE INTO posts(id, category, title) VALUES ("6dd721c52ea460135e2e9033ce7af52d", "idea_创意", "创业团队都有哪些有效的团队管理方式？");
REPLACE INTO posts(id, category, title) VALUES ("330ff1beda9001aece4581706606c1b7", "idea_创意", "创业型公司内，工作时间只有7个半小时，有个同事上班平均1小时在发表 QQ日志，上 Facebook 等情况应该怎么处理？");
REPLACE INTO posts(id, category, title) VALUES ("114a24fab8642bb2a8ab9658be3dda33", "idea_创意", "创业型公司的氛围应该是怎样的？");
REPLACE INTO posts(id, category, title) VALUES ("9fe7f91eea2465d0e0c9736361f2c538", "idea_创意", "创业小公司如何在财力有限的情况下，打造愉悦的工作环境？");
REPLACE INTO posts(id, category, title) VALUES ("f6528eb784406df0dda6abe92ef3738f", "idea_创意", "创业时，程序员要求不错的工资，又要不错的股份，这合理吗？");
REPLACE INTO posts(id, category, title) VALUES ("df1ce1f2bdcddb8faf5ab1a001543d3b", "idea_创意", "创业期如何免费获得前期流量？");
REPLACE INTO posts(id, category, title) VALUES ("17e88fdce008ebdc6854e6ac9b1e0923", "idea_创意", "创业经历教给你的最重要的东西是什么？");
REPLACE INTO posts(id, category, title) VALUES ("b66ba87e6ebff70a47e37774006ae617", "idea_创意", "创业者们你们是如何管理财务问题的？");
REPLACE INTO posts(id, category, title) VALUES ("fbc5d6289ed9a4dc8f6e046d6184edbc", "idea_创意", "创业者应该怎样面对批评和质疑？");
REPLACE INTO posts(id, category, title) VALUES ("a3105afbd75bd3fbb4a0f9075630b16b", "idea_创意", "创业适合从摆地摊开始吗？");
REPLACE INTO posts(id, category, title) VALUES ("e3056087a517fbe4080a4fea5d20fc74", "idea_创意", "创新工场投资项目失败以后，创始人和创业团队何去何从？");
REPLACE INTO posts(id, category, title) VALUES ("b6ecb512f48cd9b3a99a629221457724", "idea_创意", "创新工场能不能帮助初创业者组建一支高效的团队？");
REPLACE INTO posts(id, category, title) VALUES ("f2c2b2db617f7e4414121a75791786c2", "idea_创意", "创新工场面向所有的创业人员，但看过投资过的项目创始人，又有几个是草根创业者？");
REPLACE INTO posts(id, category, title) VALUES ("f4a5fc01830d2f3e0229cba351ecf49b", "idea_创意", "初创公司几个投资人，各占多少股份合适？");
REPLACE INTO posts(id, category, title) VALUES ("1e55847972ab6206a6c541355a637cd5", "idea_创意", "初创公司如何设置期权池（Option Pool）？如何操作？");
REPLACE INTO posts(id, category, title) VALUES ("e9ffda982340afae9c412d6caf620bb3", "idea_创意", "初次创业者最容易犯哪些错误？");
REPLACE INTO posts(id, category, title) VALUES ("ce180bc43c845d98317d06cdf6767d18", "idea_创意", "原始股与期权有什么区别？对持有人来说有什么不同？创业者一般拿到的是期权还是原始股？");
REPLACE INTO posts(id, category, title) VALUES ("770790ce22ede96bb2e91b0c12b25217", "idea_创意", "去大公司实习还是去创业公司实习好？");
REPLACE INTO posts(id, category, title) VALUES ("bc30c50697ee1c394b9395383b527bc5", "idea_创意", "去美国山寨一个豆瓣，会成功吗？");
REPLACE INTO posts(id, category, title) VALUES ("a05cc1ffd20ebb111335e9a457d8dc32", "idea_创意", "受过良好教育却又胸无大志，甘心一个月拿着几千工资的男人是不是很失败？");
REPLACE INTO posts(id, category, title) VALUES ("27490d62c441e9dec2863f0e961acb06", "idea_创意", "周鸿祎在奇虎 360 公司早期做出的最重要的四五个决定是什么？");
REPLACE INTO posts(id, category, title) VALUES ("18837a9c298dcd40150cc6b3f1253116", "idea_创意", "哪些不起眼的职业收入远超过群体平均水平？");
REPLACE INTO posts(id, category, title) VALUES ("2b3b20f00656c55eeeb15e246179db72", "idea_创意", "哪些迹象表明你的公司已经不再是创业公司了？");
REPLACE INTO posts(id, category, title) VALUES ("1e4703443fc5eba1d29a748a1edd41a3", "idea_创意", "哪里能找到商业计划书？");
REPLACE INTO posts(id, category, title) VALUES ("a83088c741c3228bf86cc67213a99622", "idea_创意", "商业计划书应该包含哪些点？看 BP 的人最想从中得到的是什么？");
REPLACE INTO posts(id, category, title) VALUES ("c38da00552736c51279a4edd20bec4f7", "idea_创意", "团队中，你是怎么带新人的？");
REPLACE INTO posts(id, category, title) VALUES ("e3b1160b36ad8e5de5e3f804996d3401", "idea_创意", "在中国的创业团队中培养工程师文化，需不需要「接地气」？如果是，理想的方式是什么？");
REPLACE INTO posts(id, category, title) VALUES ("55ca14a6e49288da57fd3c00efa81ee2", "idea_创意", "在创业公司工作，期权怎么发放？");
REPLACE INTO posts(id, category, title) VALUES ("bc527bc270c3cf6dde8602df8a62fb1f", "idea_创意", "在校大学生想创业，但是没有资金，没有人脉，没有经验，该如何起步？");
REPLACE INTO posts(id, category, title) VALUES ("1f59c011b8f28e37dab54b2a9b2270cb", "idea_创意", "坚持看新闻联播真的能致富？");
REPLACE INTO posts(id, category, title) VALUES ("919de0815236f684e74ec0e50c4c0878", "idea_创意", "大学生毕业后是直接选择创业好，还是有机会的话先进企业公司中实际工作一段时间？");
REPLACE INTO posts(id, category, title) VALUES ("b5516af3b90d6e0256d48655b0cdfc74", "idea_创意", "大家都在做什么有趣的个人项目？");
REPLACE INTO posts(id, category, title) VALUES ("400f839b0d2700343bbeea415bca5e10", "idea_创意", "天使投资与风险投资的区别是什么？");
REPLACE INTO posts(id, category, title) VALUES ("2399537bd81f5bf3a1e42c8ce7e99d73", "idea_创意", "如何从无到有地建立一个国家？");
REPLACE INTO posts(id, category, title) VALUES ("d423f8e7af47679188b47f6a568defad", "idea_创意", "如何以非员工身份向一家企业售卖自己的 idea？");
REPLACE INTO posts(id, category, title) VALUES ("72d62a0d88b0e58226e9f38d4f238542", "idea_创意", "如何做开店前的考察工作？");
REPLACE INTO posts(id, category, title) VALUES ("da5321be737b122e9352a21cb1baa3d4", "idea_创意", "如何判断一个创业公司是不是浮躁了？");
REPLACE INTO posts(id, category, title) VALUES ("501e5ece006a44f4e33b22aeb8bc8f7b", "idea_创意", "如何判断一家创业公司是否值得加入？");
REPLACE INTO posts(id, category, title) VALUES ("10e49b2ec7d1c681798258b736426a04", "idea_创意", "如何可以做好盒饭外卖？");
REPLACE INTO posts(id, category, title) VALUES ("126101af0f4897ad3f227b6726c4eece", "idea_创意", "如何向老板提出扩充团队招募新人的要求？");
REPLACE INTO posts(id, category, title) VALUES ("b24debd96f09eb58c72103028d84805c", "idea_创意", "如何才能忽悠人？尤其是忽悠人才一起创业？");
REPLACE INTO posts(id, category, title) VALUES ("5ff9f10d6a19cd696b328d8eb0e3623b", "idea_创意", "如何提高团队凝聚力和执行力？");
REPLACE INTO posts(id, category, title) VALUES ("23a2b985a902572843a6fa037a06c128", "idea_创意", "如何提高团队管理能力？");
REPLACE INTO posts(id, category, title) VALUES ("85fc6f065a9cd861e4271fadfc266cef", "idea_创意", "如何看待微博上《投资人请闭嘴：投资人最爱讲的六句“废话”》这篇文章？");
REPLACE INTO posts(id, category, title) VALUES ("97f989a3fea622911844a54e487c69ca", "idea_创意", "如何看待糗事百科站长和合作者的股权纠纷？");
REPLACE INTO posts(id, category, title) VALUES ("11fe0b2204e9ca4f6de3708d6163862c", "idea_创意", "如何记工作笔记以提高工作效率？");
REPLACE INTO posts(id, category, title) VALUES ("33e51a7f86099d49c95b7ae5eab94dfa", "idea_创意", "如何进行人脉管理？");
REPLACE INTO posts(id, category, title) VALUES ("b271fb475530b8fc87046fa4a585359c", "idea_创意", "如何选择创业方向？");
REPLACE INTO posts(id, category, title) VALUES ("cbfdb8ed314a7ddda6e3b2c490e70d8d", "idea_创意", "如果一个4人团队没有互联网方面的技术实力，但有很好的创意和强大的执行力，他们能否获得创新工场助跑计划的青睐？");
REPLACE INTO posts(id, category, title) VALUES ("ad306dde69d8799eebb4187451153855", "idea_创意", "如果一家有潜力的公司（比如知乎），薪酬不高，可能只有一两千，你还会进么？");
REPLACE INTO posts(id, category, title) VALUES ("03af582a5138e6dda2e06630ed09a296", "idea_创意", "如果你出生在三国时代，你会选择哪位主公做你的老板？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("7cf81775c3b09c336522bc30bae12ddf", "idea_创意", "如果只给你 2000 块钱，你会怎么去创业或做其他的，以赚到更多的钱？");
REPLACE INTO posts(id, category, title) VALUES ("fce9a4805e8669f16463199cf4bddf42", "idea_创意", "如果可能的话，你想开一家什么店？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("0d617d66416ce7065c5e4b9a93c79cf3", "idea_创意", "如果投资者善意提醒说，如果不接受投资，就投给对手，怎么办？");
REPLACE INTO posts(id, category, title) VALUES ("9179918ac8b1e5c14e9babacc530c744", "idea_创意", "如果有机会与天使投资人进行面对面沟通，该准备些什么？");
REPLACE INTO posts(id, category, title) VALUES ("90211e5d18a5a7dd7526ced338cc891a", "idea_创意", "如果有机会，你想创建一个什麼价值观和使命的公司？");
REPLACE INTO posts(id, category, title) VALUES ("5c84c952204e6c556dc79343e64e4197", "idea_创意", "如果给你 10 万，怎样在 3 年内创造 100 万 +？");
REPLACE INTO posts(id, category, title) VALUES ("6077c9d42985c11cd3130b0a4ff96a05", "idea_创意", "如果说我有一个改变世界的 idea，打算辞职全身心去创业，你们觉得靠谱么？");
REPLACE INTO posts(id, category, title) VALUES ("ee1094c79b180365166d64998ad9277a", "idea_创意", "对一个第一次当 CEO 的年轻人，你有哪些建议或忠告？");
REPLACE INTO posts(id, category, title) VALUES ("465e3b778ae5da9b184e24217e1c9e53", "idea_创意", "对于 TuciaBaby 创始人 meditic 的互联网创业降级论，你怎么看？");
REPLACE INTO posts(id, category, title) VALUES ("c62891f6cc94b126e24f8041070c5627", "idea_创意", "对于创业者来说，有哪些比较好的财务类入门书籍？");
REPLACE INTO posts(id, category, title) VALUES ("52b6be8d7cc96784d173778e300ff4ee", "idea_创意", "小米科技是一家怎样的公司？");
REPLACE INTO posts(id, category, title) VALUES ("22717a1ed69f0d24eb13b477adc074cf", "idea_创意", "年轻的创业者，怎样才能比较容易地拿到风险投资和天使投资？");
REPLACE INTO posts(id, category, title) VALUES ("ab62b195a0365523068533d480c6cf26", "idea_创意", "开始创业的时候，是单身比较好还是已经结婚了比较好？");
REPLACE INTO posts(id, category, title) VALUES ("697781a37f5759470a72d48fdebc3fec", "idea_创意", "开火锅店需要注意哪些事情？");
REPLACE INTO posts(id, category, title) VALUES ("9bd7e3313370f4615c7094156e39bba1", "idea_创意", "开设一家加盟便利店有什么要注意的？");
REPLACE INTO posts(id, category, title) VALUES ("069890016fcfcbdb5ec4f1d1a908e39e", "idea_创意", "德克士、麦当劳和肯德基的加盟流程和区别是怎样的？");
REPLACE INTO posts(id, category, title) VALUES ("2673553801d01eb02c92c39024267971", "idea_创意", "怎么样才能找到一个靠谱的技术合伙人？");
REPLACE INTO posts(id, category, title) VALUES ("6325ea5982dbd260540d9480ab05aa3d", "idea_创意", "怎么评价周鸿祎所说的「很多媒体人误导了创业者」？");
REPLACE INTO posts(id, category, title) VALUES ("d2a28a975f870ffe15327d48bc458fc1", "idea_创意", "怎样合法地打造一个属于自己的商业情报网络？");
REPLACE INTO posts(id, category, title) VALUES ("a7f127f9b4d1a8052eb6d5b99ac1e799", "idea_创意", "怎样开家面包店？");
REPLACE INTO posts(id, category, title) VALUES ("6c13881525845fc2c60eb054368ec774", "idea_创意", "怎样才能成为天使投资人？");
REPLACE INTO posts(id, category, title) VALUES ("a18f7a804a99025c71ec96d36adf456a", "idea_创意", "怎样解决冷启动？怎样找到种子用户？怎样抓住种子用户？");
REPLACE INTO posts(id, category, title) VALUES ("773ee95b47cd8c50119078d5f5b4fc2a", "idea_创意", "想做一本杂志，首先应该从哪里做起？");
REPLACE INTO posts(id, category, title) VALUES ("366592aa4373396025f3520944e12713", "idea_创意", "想自己创业，但现在又没好的想法，是不是只能安心的工作？");
REPLACE INTO posts(id, category, title) VALUES ("1db2217d1e4caaf71c0a14b2641b6d48", "idea_创意", "抓虾最后没有成功原因有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("98c2c9e59213374c315e0464d0b62f48", "idea_创意", "拉里·埃里森在他 32 岁创办甲骨文之前的是什么样的一个人？性格如何？");
REPLACE INTO posts(id, category, title) VALUES ("25a651ee366cbdcdc3c73de6ecd7fdaa", "idea_创意", "据说百姓网和赶集、58 同城公司人数相差 N 个数量级，关于互联网公司，尤其是新兴互联网公司的团队人数，你如何分析看待？");
REPLACE INTO posts(id, category, title) VALUES ("ddc5d5856adf904e20f3b0157c1eac64", "idea_创意", "新婚，老公要创业，没有时间陪我，我该怎么办？");
REPLACE INTO posts(id, category, title) VALUES ("908c0c94566ed5e9d5b8200bd298fd3b", "idea_创意", "星晨急便一夜倒闭是真的吗？具体是怎么回事？");
REPLACE INTO posts(id, category, title) VALUES ("eda0607e5583c394d50cdf22946ce211", "idea_创意", "是不是有许多真正的好创意并不是苦思冥想想出来的？");
REPLACE INTO posts(id, category, title) VALUES ("d26588751771420aa2f1b5416ad30046", "idea_创意", "是否绝大部分创业公司都活不过 5 年？是哪些原因让创业公司走向倒闭？");
REPLACE INTO posts(id, category, title) VALUES ("aaf8ec9c3000be8e9f689d67b2488d64", "idea_创意", "最近一百年，全球涌现过哪些最顶尖的、最赚钱的公司？它们的共性是什么？");
REPLACE INTO posts(id, category, title) VALUES ("3aaae1a35a73722372e1b49343c2c3dc", "idea_创意", "有 1000 万资金，该怎么去经营一个互联网创业项目？");
REPLACE INTO posts(id, category, title) VALUES ("955e004a1e64e86cfd7a59c29ac52ae8", "idea_创意", "有梦想，有素质的新人愿意从客服开始做起吗？");
REPLACE INTO posts(id, category, title) VALUES ("ed8007740680893ee51a5f3f079dcc85", "idea_创意", "有项目，少量投资，怎么寻找技术合伙人？");
REPLACE INTO posts(id, category, title) VALUES ("31afd1d31a2dff8684ef3ed19ac8041f", "idea_创意", "未来五年最值得创业的是哪个行业？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("be9f66c402d4e11980f1ebca0d92a5db", "idea_创意", "未来十年，你最看好的行业有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("c0245caf31ff5ef0fc94d2204d7ee781", "idea_创意", "本科非 211 类学校毕业，申请复旦_交大的全日制MBA的可能性大吗？如果顺利毕业，进入券商投行部的概率有多少？进入 PE 或者 VC 呢？");
REPLACE INTO posts(id, category, title) VALUES ("86a9734c90ca59dac4a50523b9d137ac", "idea_创意", "玩具电商为什么做不大？");
REPLACE INTO posts(id, category, title) VALUES ("0121a964bb3f2d4ab7ca9dd5bb5d1740", "idea_创意", "用吧台形式卖咖啡，用和 40 块钱的咖啡同样的原材料，售价在咖啡厅的 30%-50% 之间，这样可行吗？");
REPLACE INTO posts(id, category, title) VALUES ("536987bab597341af66c9b61553cdd9e", "idea_创意", "白手起家还适应我们这个年代吗？是否还有人能真正做到？");
REPLACE INTO posts(id, category, title) VALUES ("caea790fc883840be481867212d36788", "idea_创意", "目前国内比较出名的天使投资人有哪些？他们有哪些比较成功的投资案例？");
REPLACE INTO posts(id, category, title) VALUES ("29cd43eed4d4ef826e299363a8dbfc45", "idea_创意", "目前有哪类移动互联网创业项目，属于做的人很多、但投资人很谨慎的？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("b0d3b664e647b58818164d3c00b2d2c2", "idea_创意", "知乎上关于创业团队、创业融资、股权结构、法律、经验分享等精彩系列问答有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("06efdb1c88783e225bff64cb6a9dbed4", "idea_创意", "知乎工程师工资多少？其他待遇怎么样？");
REPLACE INTO posts(id, category, title) VALUES ("84f0f1e7663f9d8669a71ff00930e71a", "idea_创意", "社交游戏开发公司 Zynga 迅速成功的原因有哪些？");
REPLACE INTO posts(id, category, title) VALUES ("9ac07b07990df74ab2b58a2ac7d74911", "idea_创意", "移动互联网 App 泡沫即将破灭吗？为什么？");
REPLACE INTO posts(id, category, title) VALUES ("537e16d734534782ec856cf1eb885b3e", "idea_创意", "第一次创业的人通常都有哪些能力缺陷？");
REPLACE INTO posts(id, category, title) VALUES ("c6c9fdba06f2886fae555b454d7b0896", "idea_创意", "给你5万、50万、500万，你会分别怎么创业？");
REPLACE INTO posts(id, category, title) VALUES ("19432474fcec1269845f87b94ff05e0d", "idea_创意", "罗永浩准备搞个手机公司了，自诩不比乔布斯差，靠谱吗？");
REPLACE INTO posts(id, category, title) VALUES ("4a89726dd8398926f78b641c0393e98b", "idea_创意", "要是我穿越到 1997 年去「山寨」微博，我能大赚一笔或者出名吗？");
REPLACE INTO posts(id, category, title) VALUES ("fadf81d5cfa6cfd685cba07b44104420", "idea_创意", "译言网与东西网分家然后又合并，这后面是怎么一回事？");
REPLACE INTO posts(id, category, title) VALUES ("bb04380d737b1854037457352a1c750d", "idea_创意", "课程格子用户超百万规模时团队只有 4 人，这是如何做到的？");
REPLACE INTO posts(id, category, title) VALUES ("59d18286359ecf2d27a443c309be8f3c", "idea_创意", "豆瓣、果壳、点点是怎样解决冷启动的问题的？如果是你来运营一个刚出生的产品，会怎么做呢？");
REPLACE INTO posts(id, category, title) VALUES ("65705527cacaec135ea8a00bf7c566b4", "idea_创意", "采访过马化腾的记者们，能否把你们以前的采访记录（录音或笔录）择要放出？");
REPLACE INTO posts(id, category, title) VALUES ("de8857f350191c79bcc5791ff4248c57", "idea_创意", "阿北在豆瓣早期做出的最重要的四五个决定是什么？");
REPLACE INTO posts(id, category, title) VALUES ("abfe81eec1bf0564a9e86e37bcf27ffc", "idea_创意", "雷军系和创新工场系，到底谁在竞争中的卡位更准一些？双方各有哪些比较优势呢？");
REPLACE INTO posts(id, category, title) VALUES ("d89107039d615003afad5769d1821218", "idea_创意", "风投与创业公司如何运作才能双赢？");
REPLACE INTO posts(id, category, title) VALUES ("771a452594cbbb26687fb996576d906b", "idea_创意", "风险投资（VC）公司职员的收入构成如何？");
