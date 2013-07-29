#!/bin/bash
##-------------------------------------------------------------------
## @copyright 2013 ShopEx Network Technology Co,.Ltd
## File : postwasher.sh
## Author : filebat <markfilebat@126.com>
## Description :
## --
## Created : <2013-07-27>
## Updated: Time-stamp: <2013-07-28 14:54:26>
##-------------------------------------------------------------------

category=${1?}
dir="$XZB_HOME/webcrawler_data/$category"

cd $dir

for d in `find . -type d -exec ls -d {} \; | grep -v "_raw"`;
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
    done;
done;

mkdir -p $dir/done_postwasher_raw
# classify too short articles as low quality
find . -size -1k -a -type f -iname "*.data" -print0 | xargs -I{} -0 mv "{}" done_postwasher_raw/"{}"

## File : postwasher.sh ends
