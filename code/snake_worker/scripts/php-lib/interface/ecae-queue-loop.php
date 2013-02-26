<?php
interface ecae_queue_loop{
    
    public function start();

    public function run($arg);

    public function stop();
}
