<?php
#require(dirname($_SERVER["PHP_SELF"])."/../ecae-libs.php");
require(dirname($_SERVER["PHP_SELF"])."/./interface/ecae-queue-loop.php");
class php_loop
{

    public static function start($loop_name) { 
        $obj = new $loop_name();
        if($obj instanceof ecae_queue_loop){
            $obj->start();
            Echo"Start\n"; 
            php_loop::run($obj);
        } else {
            Echo "Failed: is not instance ecae_queue_loop quit\n";   
            php_loop::stop();
        }
    }
    public static function run($obj) {
        $fp = fopen('php://stdin', 'r');
        #while($line = fgets($fp, 4096)) {
        while($line = fgets($fp)) {
            if($line == "Quit") {
                php_loop::stop($obj);
                break;
            } elseif(substr($line,0,4)=="Arg:") {
                $arg = substr($line,4);
                if($obj->run($arg)){
                    Echo "Done\n";
                } else {
                    Echo "Failed\n";
                } 
            } else {
                Echo "Failed: unknow stdin args!\n";
                php_loop::stop($obj);
                break;
            }
        }
    }
    public static function stop($obj=null) {
        if($obj)$obj->stop();
        Echo "Stop\n";
        exit();
    }
}
$args = $_SERVER['argv'];
if(!$args[1]) echo "Failed: args Failed, php loop_name not exists!\n";

#error_log(print_r($_SERVER,1)."\n",3,"/tmp/aa.log");

#include "/var/www/ecae-run/sites/2276/scripts/".$args[1];
include $args[1];
$class = basename(substr($args[1], 0,strpos($args[1],".")));

php_loop::start($class);



