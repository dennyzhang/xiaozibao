# 10,40 * * * * source /etc/profile; (sh $XZB_HOME/code/tool/crontab_update.sh 2>&1) 1>> $XZB_HOME/cron.log

git pull
git commit -am "schedule commit" && git push || true
make regenerate_feedback
