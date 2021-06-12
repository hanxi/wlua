#!/bin/sh

#####################################################################
# usage:
# sh stop.sh
#####################################################################

. ./.env
mkdir -p ${WLUA_APP_RUN_DIR}
echo "reload" > ${WLUA_APP_RUN_DIR}/sighup
kill -1 $(cat ${WLUA_APP_RUN_DIR}/${WLUA_APP_NAME}.pid)
sleep 1
echo "" > ${WLUA_APP_RUN_DIR}/sighup
