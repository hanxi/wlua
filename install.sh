set -x

BIN=$1
INSTALLDIR=$2
V_INSTALLDIR=${INSTALLDIR//\//\\\/} 
INSTALL=/usr/bin/install
${INSTALL} -d ${INSTALLDIR}
cp -rf conf ${INSTALLDIR}/conf
cp -rf demo ${INSTALLDIR}/demo
${INSTALL} -p -D demo/.env ${INSTALLDIR}/demo/.env
cp -rf luaclib ${INSTALLDIR}/luaclib
cp -rf lualib ${INSTALLDIR}/lualib
cp -rf service ${INSTALLDIR}/service
${INSTALL} -d ${INSTALLDIR}/skynet
cp -rf skynet/cservice ${INSTALLDIR}/skynet/cservice
cp -rf skynet/luaclib ${INSTALLDIR}/skynet/luaclib
cp -rf skynet/lualib ${INSTALLDIR}/skynet/lualib
cp -rf skynet/service ${INSTALLDIR}/skynet/service
${INSTALL} -p -D -m 0755 skynet/skynet ${INSTALLDIR}/skynet/skynet
${INSTALL} -p -D -m 0755 wlua ${INSTALLDIR}/wlua
sed -i 's/REPLACE_INSTALL_PATH/'$V_INSTALLDIR'/g' ${INSTALLDIR}/wlua
ln -sf ${INSTALLDIR}/wlua ${BIN}
