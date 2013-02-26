<?php

class test implements ecae_queue_loop{
    public function start() {
    
    }


    public function run($arg)
    {
        `touch /tmp/$arg`;
        return true;
    }


    public function stop()
    {
    }
}
