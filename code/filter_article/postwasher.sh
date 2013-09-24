#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013 ShopEx Network Technology Co,.Ltd
## File : postwasher.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-07-27>
## Updated: Time-stamp: <2013-09-24 00:09:39>
##-------------------------------------------------------------------

category=${1?}
dir="$XZB_HOME/webcrawler_data/$category"

cd $dir
mkdir -p $dir/done_postwasher_raw

for d in `find . -type d -exec ls -d {} \; | grep -v "_raw" | grep -v '^.$'`;
do
    for f in $d/*.data;
    do
        #echo "$f"
        grep "status: " "$f"
        if [ $? -eq 0 ]; then
            # add newline, if necessary
            perl -i -p -e 's/\n/\n\n/' "$f" && \
                sed -ie "s/status: /status:REPLACED_NEWLINE/g" "$f" && \
                perl -0777 -i -pe 's/\n\n+/\n\n/g' "$f"
        fi;

        # replace " to '
        sed -ie "s/\"/'/g" "$f"
        rm -rf "${f}e"

        # classify too short articles as low quality
        if [ `wc -c "${f}" | awk -F' ' '{print $1}'` -le 1000 ]; then
            mv "$f" "./done_postwasher_raw/`basename "$f"`"
        fi;
    done;
done;

## File : postwasher.sh ends
