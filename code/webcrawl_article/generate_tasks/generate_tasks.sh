#!/bin/bash -e
##-------------------------------------------------------------------
## File : generate_tasks.sh
## Author : filebat <filebat.mark@gmail.com>
## Description :
## --
## Created : <2014-01-11>
## Updated: Time-stamp: <2014-01-11 11:07:18>
##-------------------------------------------------------------------
function log()
{
    local msg=${1?}
    echo -ne `date +['%Y-%m-%d %H:%M:%S']`" $msg\n"
}

function generate_all()
{
    for f in `ls fetch_*.sh `;
    do echo $f && ./$f;
    done
}

# TODO: more imperative
command=${1?}

if [ "$command" = "generate_all" ]; then
    generate_all
fi;


## File : generate_tasks.sh ends
