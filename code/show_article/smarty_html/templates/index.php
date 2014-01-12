<?php
date_default_timezone_set('Asia/Shanghai');
$date = date('Ymd', time());
$htmlFile = file("/home/wwwroot/dennytest.youwen.im/"+$date+".html");
echo(implode('',$htmlFile));