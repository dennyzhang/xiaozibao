#!/bin/sh

#disable_classes="XMLWriter,DOMNotation,SQLiteDatabase,SQLiteResult,SQLiteUnbuffered,SQLiteException,xhprof"
disable_classes=""
#disable_functions="php_real_logo_guid,php_egg_logo_guid,php_ini_scanned_files,php_ini_loaded_file,readlink,session_set_save_handler,linkinfo,symlink,link,exec,system,escapeshellcmd,escapeshellarg,passthru,shell_exec,proc_open,proc_close,proc_terminate,proc_get_status,proc_nice,getmyuid,getmygid,getmyinode,putenv,getopt,sys_getloadavg,getrusage,get_current_user,magic_quotes_runtime,set_magic_quotes_runtime,import_request_variables,debug_zval_dump,ini_alter,dl,pclose,popen,stream_select,stream_filter_prepend,stream_filter_append,stream_filter_remove,stream_socket_client,stream_socket_server,stream_socket_accept,stream_socket_get_name,stream_socket_recvfrom,stream_socket_sendto,stream_socket_enable_crypto,stream_socket_shutdown,stream_socket_pair,stream_copy_to_stream,stream_get_contents,stream_set_write_buffer,set_file_buffer,set_socket_blocking,stream_set_blocking,socket_set_blocking,stream_get_meta_data,stream_get_line,stream_register_wrapper,stream_wrapper_restore,stream_get_transports,stream_is_local,get_headers,stream_set_timeout,socket_get_status,openlog,closelog,apc_add,apc_clear_cache,apc_compile_file,apc_define_constants,apc_delete,apc_load_constants,apc_sma_info,apc_store,flock,fsockopen,pfsockopen,posix_kill,apache_child_terminate,apache_get_modules,apache_get_version,apache_getenv,apache_lookup_uri,apache_reset_timeout,apache_response_headers,apache_setenv,virtual,mysql_pconnect,memcache_add_server,memcache_connect,memcache_pconnect"
disable_functions=""

phptmpdir=$php_tmpdir

if [ ! -d $php_tmpdir ]; then
mkdir -p $php_tmpdir
chmod 0755 $php_tmpdir
chown $site_id:$gid $php_tmpdir
fi

if [ ! -d $php_updir ]; then
mkdir -p $php_updir
chmod 0755 $php_updir
chown $site_id:$gid $php_updir
fi

scripts_path=$scripts_path/php-lib/

open_basedir=$site_path:$scripts_path
include_path=$site_path:$scripts_path

command="$php_binary_path \
 -d open_basedir=$open_basedir \
 -d upload_tmp_dir=$php_updir \
 -d include_path=$include_path \
 -d disable_functions=$disable_functions \
 -d disable_classes=$disable_classes \
 $phpini \
  $scripts_path/php-loop.php $loop_name \"$arg\""

# TODO: customize more parameters
# TODO: get php file location dynamically

#for i in $(env | awk -F"=" '{print $1}') ; do
#unset $i ; done

export TMPDIR=$phptmpdir
#command="launch '$command'"
eval $command
