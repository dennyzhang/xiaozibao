-- mysql -uuser_2013 -pilovechina xzb < $XZB_HOME/code/tool/update_db.sql

use xzb;

-- set category default post id
call deliver_default_post("2013-02-02", "health", "bcaee5988105f72f336e343c0e00fbfc", "");
call deliver_default_post("2013-02-02", "joke", "a56261745aaa629dd5b17af0c2769016", "");
call deliver_default_post("2013-02-02", "lifehack", "5c2b25372d03bca19e68667d45915899", "");

-- Manual config for deliver strategy
call replace_post("grace", "health", "2013-02-02", "051fd6a35ad0dc031436b1ab21e440f7", "");
call replace_post("zan", "health", "2013-02-02", "051fd6a35ad0dc031436b1ab21e440f7", "");

---------------------------- checkpoint -------------------------
call deliver_default_post("2013-02-03", "health", "15441dd998f1331a2ac290ce7853f101", "");
call deliver_default_post("2013-02-03", "joke", "4059731ebb3d45a476769dad035246df", "");
call deliver_default_post("2013-02-03", "lifehack", "c2bba680da6040350188fb61cce7f639", "");

call deliver_default_post("2013-02-04", "health", "9b866551ff32feb370c631fcfac507a6", "");
call deliver_default_post("2013-02-04", "joke", "a99ed41186a35f80e6143b985b5b8b01", "");
call deliver_default_post("2013-02-04", "lifehack", "d8e7974f9e7f157a5ff3c3954417784b", "");
call replace_post("sophia", "joke", "2013-02-04", "e4a8496603a400a31fd977d9b7d26508", "");
call replace_post("grace", "joke", "2013-02-04", "e4a8496603a400a31fd977d9b7d26508", "");
call replace_post("clare", "joke", "2013-02-04", "e4a8496603a400a31fd977d9b7d26508", "");
call replace_post("jim", "joke", "2013-02-04", "e4a8496603a400a31fd977d9b7d26508", "");

call deliver_default_post("2013-02-05", "health", "2dd157f2ad31d857f968fc2bd136f756", "");
call deliver_default_post("2013-02-05", "joke", "38d7046a5682b06bc9f5880d90f7df6c", "");
call deliver_default_post("2013-02-05", "lifehack", "110e8e73977b99b55647d4b211a79a74", "");
call replace_post("denny", "health", "2013-02-05", "6e7df1370f39e9f56558b5dd6a1ca1d1", "");
call replace_post("denny", "joke", "2013-02-05", "6dc1978520111b66235d2ebcf5dd6e60", "");
call replace_post("denny", "lifehack", "2013-02-05", "985c23ecc2f2e186332f65d174ce00ba", "");

call deliver_default_post("2013-02-06", "health", "c83191cbde5b5b465b62003bb1c79d3a", "");
call deliver_default_post("2013-02-06", "joke", "7af9b51d8ae679e662aef0099c158ca5", "");
call deliver_default_post("2013-02-06", "lifehack", "eb6101bd1ff94159bc9dbaf18a6a6aa0", "");

call deliver_default_post("2013-02-07", "health", "ae0f3772127a592a41b6516c64e94d47", "");
call deliver_default_post("2013-02-07", "joke", "e9243a802897b837319455d825b16d6e", "");
call deliver_default_post("2013-02-07", "lifehack", "35c9caddda23dd2d84322639cde98971", "");

call deliver_default_post("2013-02-08", "health", "8cced68f679513baaac379b59ff8c67e", "");
call deliver_default_post("2013-02-08", "joke", "6dc1978520111b66235d2ebcf5dd6e60", "");
call deliver_default_post("2013-02-08", "lifehack", "75ec01b74672046d542f8dbab5757993", "");


call deliver_default_post("2013-02-09", "entrepreneur", "b25d4abf78661b16f195110f311a44db", "");
call deliver_default_post("2013-02-09", "joke", "e2e29f84cf82e4a09348e669cf6055a8", "");
call deliver_default_post("2013-02-09", "lifehack", "311672306548a774f9e6490428ea8e6a", "");

call deliver_default_post("2013-02-10", "entrepreneur", "0edf7457fc1bcbbd223f432bc509ff77", "");
call deliver_default_post("2013-02-10", "joke", "89a97a50d58ad8de81c3e8132c0b4b7c", "");
call deliver_default_post("2013-02-10", "lifehack", "d9c826b594c06de48fb0ecff140fc25d", "");

call deliver_default_post("2013-02-11", "entrepreneur", "0497946a962915d9bfb7137ba924d401", "");
call deliver_default_post("2013-02-11", "joke", "66489ff2751e62bee516562190b48408", "");
call deliver_default_post("2013-02-11", "lifehack", "27383a048b075678dffca524e1f8296f", "");
call replace_post("sjembn", "lifehack", "2013-02-11", "029df573add8b78a8cf07db62c5af234", "");
call replace_post("allen", "lifehack", "2013-02-11", "029df573add8b78a8cf07db62c5af234", "");
call replace_post("colin", "lifehack", "2013-02-11", "029df573add8b78a8cf07db62c5af234", "");
call replace_post("sophia", "joke", "2013-02-11", "da1934d9b10ccf67dacdca0637b3b3fa", "danmei");
call replace_post("grace", "joke", "2013-02-11", "da1934d9b10ccf67dacdca0637b3b3fa", "danmei");
call replace_post("clare", "joke", "2013-02-11", "da1934d9b10ccf67dacdca0637b3b3fa", "danmei");

call deliver_default_post("2013-02-12", "entrepreneur", "8c66d2323d1ce773afb07f87dfcd9509", "");
call deliver_default_post("2013-02-12", "joke", "21d672a351e6ea1528ed6be98f1c89f4", "");
call deliver_default_post("2013-02-12", "lifehack", "4ffda5749fcd85dd030b8a6c71b46c76", "");
call replace_post("sophia", "joke", "2013-02-12", "29ec758cbb4379cb58092e1142fdfd59", "danmei");
call replace_post("grace", "joke", "2013-02-12", "29ec758cbb4379cb58092e1142fdfd59", "danmei");
call replace_post("clare", "joke", "2013-02-12", "29ec758cbb4379cb58092e1142fdfd59", "danmei");


call load_schedule_update("denny", "intenermonitor", "ac649eee646bb5055dace9a68f5d39af");
call load_schedule_update("haijun", "intenermonitor", "159829e79c0cc7213f8a40dbbbf0f939");
call load_schedule_update("sophia", "intenermonitor", "c6513dfeae38b4b3afe44583b8fafed8");
call load_schedule_update("yao", "intenermonitor", "9ca9eb0fb4500a62d6336ee91d3856be");
call load_schedule_update("liki", "intenermonitor", "c0ab79fbeb39539dc5fc7810ed31bbe8");
call load_schedule_update("colin", "intenermonitor", "1724d40d4579eadf19210eb3387579ee");
call load_schedule_update("allen", "intenermonitor", "40a4aa2851d14e88960eecf529c264ba");
call load_schedule_update("zan", "intenermonitor", "bf7ed8ea7938145deae4908b6c57f940");
call load_schedule_update("ning", "intenermonitor", "fbe5fc7bfbffa3f6d1fc37ae452a0949");
call load_schedule_update("sjembn", "intenermonitor", "a3068c07b22d0ec862c17848606e9484");
call load_schedule_update("clare", "intenermonitor", "bee27147de2fa49a8421b7fab32f2b31");
call load_schedule_update("jim", "intenermonitor", "ee1da3ecfd5eef5ddfa0c93d9de378c0");
call load_schedule_update("yuki", "intenermonitor", "0b173d733055594d5898e8fd74df024c");
--########################## checkpoint ###########################################
call deliver_default_post("2013-02-13", "joke", "c0b2ec68872b2fd4acbf1c0a40504651", "");
call deliver_default_post("2013-02-13", "lifehack", "297319598e5aa32d416557dae2a27a88", "");
call deliver_default_post("2013-02-13", "entrepreneur", "a5e03f7a12ecb15a15af1766205cc125", "");
call replace_post("sophia", "joke", "2013-02-13", "9b7f204b85bb6252e232bc7fbd31cb21", "danmei");
call replace_post("grace", "joke", "2013-02-13", "9b7f204b85bb6252e232bc7fbd31cb21", "danmei");
call replace_post("clare", "joke", "2013-02-13", "9b7f204b85bb6252e232bc7fbd31cb21", "danmei");

call deliver_default_post("2013-02-14", "food", "bc1c3273a29dddc00fbdc3ec76197317", "");
call deliver_default_post("2013-02-14", "entrepreneur", "f6e99eb335537fc4dae53ca795a90554", "");
call deliver_default_post("2013-02-14", "society", "dff1920fd09691312c04181efe6804d7", "");
call deliver_default_post("2013-02-14", "joke", "00668bd2384ca48f83f71d6717a68bd2", "");
call replace_post("sophia", "joke", "2013-02-14", "0ba8a4cec1a9d1ade4d11324788ed9c3", "danmei");
call replace_post("grace", "joke", "2013-02-14", "0ba8a4cec1a9d1ade4d11324788ed9c3", "danmei");
call replace_post("clare", "joke", "2013-02-14", "0ba8a4cec1a9d1ade4d11324788ed9c3", "danmei");

call deliver_default_post("2013-02-15", "food", "7b66acbfce718e3918433f9131b07e2d", "");
call deliver_default_post("2013-02-15", "entrepreneur", "2cf5fb4dc2e8dae266db8eb4232cbe37", "");
call deliver_default_post("2013-02-15", "society", "33fe39a74a7b1b0927a4700e8b6e342a", "");
call deliver_default_post("2013-02-15", "joke", "cd1442750355ec765c7a8bc4e550c4dc", "");
call replace_post("sophia", "joke", "2013-02-15", "673cd58829122ae4868b83b667ba1510", "danmei");
call replace_post("grace", "joke", "2013-02-15", "673cd58829122ae4868b83b667ba1510", "danmei");
call replace_post("clare", "joke", "2013-02-15", "673cd58829122ae4868b83b667ba1510", "danmei");

call deliver_default_post("2013-02-16", "food", "5021f1a6ed1718e1626acbc9052c5a87", "");
call deliver_default_post("2013-02-16", "entrepreneur", "07e897acb0c15e94b256569e061381a9", "");
call deliver_default_post("2013-02-16", "society", "ab1cfb815d151ceea228dafa8c2f8190", "");
call deliver_default_post("2013-02-16", "joke", "22d3ab23c7ff606edbe17d68a7902e18", "");
call replace_post("sophia", "joke", "2013-02-16", "7fd2289e263fb9cdeb29a9d5ae55ab42", "danmei");
call replace_post("grace", "joke", "2013-02-16", "7fd2289e263fb9cdeb29a9d5ae55ab42", "danmei");
call replace_post("clare", "joke", "2013-02-16", "7fd2289e263fb9cdeb29a9d5ae55ab42", "danmei");

call deliver_default_post("2013-02-17", "food", "f3746ae6441c721df49ac71d5f9006ee", "");
call deliver_default_post("2013-02-17", "society", "5241bf65e6096c948e5faffbdb813e9d", "");
call deliver_default_post("2013-02-17", "joke", "2dd3ae3bd8a9537ab54d6add79fa00eb", "");
call replace_post("sophia", "joke", "2013-02-17", "ffbfcd9586b125b12169a73692d7de8e", "danmei");
call replace_post("grace", "joke", "2013-02-17", "ffbfcd9586b125b12169a73692d7de8e", "danmei");
call replace_post("clare", "joke", "2013-02-17", "ffbfcd9586b125b12169a73692d7de8e", "danmei");
