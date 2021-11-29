set -x

install_dir()
{
    rm -r "$2"
    cp -rf "$1" "$2"
}

WLUA_BIN=$1
WLUA_HOME=$2
V_WLUA_HOME=${WLUA_HOME//\//\\\/} 
INSTALL=/usr/bin/install
${INSTALL} -d ${WLUA_HOME}
install_dir conf ${WLUA_HOME}/conf
install_dir demo ${WLUA_HOME}/demo
${INSTALL} -p -D demo/.env ${WLUA_HOME}/demo/.env
install_dir luaclib ${WLUA_HOME}/luaclib
install_dir lualib ${WLUA_HOME}/lualib
install_dir service ${WLUA_HOME}/service
${INSTALL} -d ${WLUA_HOME}/skynet
install_dir skynet/cservice ${WLUA_HOME}/skynet/cservice
install_dir skynet/luaclib ${WLUA_HOME}/skynet/luaclib
install_dir skynet/lualib ${WLUA_HOME}/skynet/lualib
install_dir skynet/service ${WLUA_HOME}/skynet/service
${INSTALL} -p -D -m 0755 skynet/skynet ${WLUA_HOME}/skynet/skynet
${INSTALL} -p -D -m 0755 wlua ${WLUA_HOME}/wlua
sed -i 's/REPLACE_INSTALL_PATH/'$V_WLUA_HOME'/g' ${WLUA_HOME}/wlua
ln -sf ${WLUA_HOME}/wlua ${WLUA_BIN}

