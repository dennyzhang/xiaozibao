#!/bin/bash -e
##-------------------------------------------------------------------
## File : update_post_feedback.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-03-17>
## Updated: Time-stamp: <2014-03-17 01:24:10>
##-------------------------------------------------------------------
echo "clean old feedback first"
python -c "import update_post_feedback; update_post_feedback.clean_old_feedback_first()"
for file in `ls $XZB_HOME/feedback/*xzb_feedback.log*`
do
    echo "./update_post_feedback.py $file"
    python ./update_post_feedback.py $file
done
## File : update_post_feedback.sh ends
