#!/bin/bash

version=0.0.1
INSTALL_PATH=REPLACE_INSTALL_PATH

function usage()
{
    echo "wlua ${version}, a web framework for Lua that is as simple as it is powerful."
    echo ""
    echo "Usage: wlua COMMAND [OPTIONS]"
    echo ""
    echo "Commands:"
    echo " new <name>    Create a new application"
    echo " start         Start the server"
    echo " stop          Stop the server"
    echo " reload        Reload the server"
    echo " version       Show version of wlua"
    echo " help          Show help tips"
}

function create_new_app()
{
    if [ -z $1 ]; then
        echo "Need name"
        usage
        exit 1
    fi
    if [[ -f $1 || -d $1 ]]; then
        echo "$1 Already Exist"
        exit 2
    fi
    cp -rf ${INSTALL_PATH}/demo $1
    env_file=$1/.env
    V_INSTALL_PATH=${INSTALL_PATH//\//\\\/} 
    sed -i 's/REPLACE_WLUA_DIR/'$V_INSTALL_PATH'/g' $env_file
    sed -i 's/REPLACE_WLUA_APP_NAME/'$1'/g' $env_file
}

function start_server()
{
    echo "start server"
    if [ ! -f start.sh ]; then
        echo "start.sh file not in this directory"
        exit 1
    fi
    sh start.sh
}

function stop_server()
{
    echo "stop server"
    if [ ! -f stop.sh ]; then
        echo "stop.sh file not in this directory"
        exit 1
    fi
    sh stop.sh
}

function reload_server()
{
    echo "reload server"
    if [ ! -f reload.sh ]; then
        echo "reload.sh file not in this directory"
        exit 1
    fi
    sh reload.sh
}

function print_version()
{
    echo ${version}
}

case $1 in
    new)
        create_new_app $2
        ;;
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    reload)
        reload_server
        ;;
    version)
        print_version
        ;;
    help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac

