# 10,40 * * * * source /etc/profile; (sh $XZB_HOME/code/tool/crontab_update.sh 2>&1) 1>> $XZB_HOME/cron.log

cd $XZB_HOME
(git pull | grep feedback.log) && should_restart="yes"
git commit -am "schedule commit" && git push || true
make update_feedback

if [[ "$should_restart" = "yes" ]]; then
    echo "should restart service"
    pid=$(lsof -i tcp:9180 | grep LISTEN | awk -F' ' '{print $2}')
    [ -n $pid ] && kill -9 $pid
    make start
fi;