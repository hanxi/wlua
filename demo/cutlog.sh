#!/bin/sh

#####################################################################
# usage:
# sh cutlog.sh
#####################################################################

. ./.env
mkdir -p ${WLUA_APP_RUN_DIR}
t=$(date +"%Y%m%d%H%M%S")
mv ${WLUA_APP_LOG_DIR}/error.log ${WLUA_APP_LOG_DIR}/error.log.${t}
echo "cutlog" > ${WLUA_APP_RUN_DIR}/sighup
kill -1 $(cat ${WLUA_APP_RUN_DIR}/${WLUA_APP_NAME}.pid)
sleep 1
echo "" > ${WLUA_APP_RUN_DIR}/sighup
