set -x

WLUA_BIN=$1
WLUA_HOME=$2
V_WLUA_HOME=${WLUA_HOME//\//\\\/} 
INSTALL=/usr/bin/install
rm -rf ${WLUA_HOME}
${INSTALL} -d ${WLUA_HOME}
cp -rf conf ${WLUA_HOME}/conf
cp -rf demo ${WLUA_HOME}/demo
${INSTALL} -p -D demo/.env ${WLUA_HOME}/demo/.env
cp -rf luaclib ${WLUA_HOME}/luaclib
cp -rf lualib ${WLUA_HOME}/lualib
cp -rf service ${WLUA_HOME}/service
${INSTALL} -d ${WLUA_HOME}/skynet
cp -rf skynet/cservice ${WLUA_HOME}/skynet/cservice
cp -rf skynet/luaclib ${WLUA_HOME}/skynet/luaclib
cp -rf skynet/lualib ${WLUA_HOME}/skynet/lualib
cp -rf skynet/service ${WLUA_HOME}/skynet/service
${INSTALL} -p -D -m 0755 skynet/skynet ${WLUA_HOME}/skynet/skynet
${INSTALL} -p -D -m 0755 wlua ${WLUA_HOME}/wlua
sed -i 's/REPLACE_INSTALL_PATH/'$V_WLUA_HOME'/g' ${WLUA_HOME}/wlua
ln -sf ${WLUA_HOME}/wlua ${WLUA_BIN}

