#!/bin/sh

#####################################################################
# usage:
# sh start.sh
#####################################################################

. ./.env
mkdir -p ${WLUA_APP_RUN_DIR}
mkdir -p ${WLUA_APP_LOG_DIR}
${WLUA_DIR}/skynet/skynet ${WLUA_DIR}/conf/wlua.conf
