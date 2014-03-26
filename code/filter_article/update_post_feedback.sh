#!/bin/bash -e
##-------------------------------------------------------------------
## File : update_post_feedback.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-03-17>
## Updated: Time-stamp: <2014-03-26 00:45:08>
##-------------------------------------------------------------------
echo "clean old feedback first"
# TODO
python ./update_post_feedback.py generate_flagfile
for file in `ls $XZB_HOME/feedback/*xzb_feedback.log*`
do
    echo "./update_post_feedback.py $file"
    python ./update_post_feedback.py update_feedabck $file
done
python ./update_post_feedback.py clean_flagfile
## File : update_post_feedback.sh ends
