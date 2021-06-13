.PHONY: check skynet 3rd

all: 3rd check

3rd: skynet
	git submodule update --init
	cd 3rd/lua-cjson && $(MAKE) install LUA_INCLUDE_DIR=../../skynet/3rd/lua DESTDIR=../.. LUA_CMODULE_DIR=./luaclib CC='$(CC) -std=gnu99'
	cd 3rd/lua-r3 && $(MAKE) LUA_INCLUDE_DIR=../../skynet/3rd/lua && cp r3.lua ../../lualib/r3.lua && cp r3.so ../../luaclib/r3.so

skynet:
	git submodule update --init
	cd skynet && $(MAKE) linux TLS_MODULE=ltls

clean:
	rm -f luaclib/*.so

cleanall: clean
	cd 3rd/lua-cjson && make clean
	cd 3rd/lua-r3 && make clean
	cd skynet && make cleanall

check:
	luacheck `find . -name '*.lua' '!' -path './skynet/*' '!' -path './3rd/*' | xargs` --ignore 212/self

WLUA_BIN := /usr/local/bin/wlua
WLUA_HOME := /usr/local/wlua
install: skynet 3rd
	bash install.sh $(WLUA_BIN) $(WLUA_HOME)

uninstall:
	rm -f $(WLUA_BIN)
	rm -rf $(WLUA_HOME)
