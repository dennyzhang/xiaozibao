#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013 ShopEx Network Technology Co,.Ltd
## File : postwasher.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-07-27>
## Updated: Time-stamp: <2013-07-27 17:38:24>
##-------------------------------------------------------------------

#dir=${1?}
dir="/Users/mac/backup/essential/Dropbox/private_data/code/xiaozibao/webcrawler_data/personal_finance/money_stackexchange_com"
# classify too short articles as low quality
find $dir -size -1k -a -type f -iname "*.data" -print0 | xargs -I{} -0 mv "{}" raw/"{}"

for f in $dir/*.data;
do
    echo "$f"
    grep "status: " "$f"
    if [ $? -eq 0 ]; then
        # add newline, if necessary
        perl -i -p -e 's/\n/\n\n/' "$f" && \
        sed -ie "s/status: /status:REPLACED_NEWLINE/g" "$f"        
    fi;

    # replace " to '
    sed -ie "s/\"/'/g" "$f"
    rm "${f}e"
done;

## File : postwasher.sh ends
