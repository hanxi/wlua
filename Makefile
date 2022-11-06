.PHONY: check skynet 3rd

all: 3rd check

3rd: skynet
	git submodule update --init
	cd 3rd/lua-cjson && $(MAKE) install LUA_INCLUDE_DIR=../../skynet/3rd/lua DESTDIR=../.. LUA_CMODULE_DIR=./luaclib CC='$(CC) -std=gnu99'
	cd 3rd/lua-rax && $(MAKE) LUA_INCLUDE_DIR=../../skynet/3rd/lua && cp rax.so ../../luaclib/rax.so && cp rax.lua ../../lualib/rax.lua

skynet:
	git submodule update --init
	cd skynet && $(MAKE) linux TLS_MODULE=ltls

clean:
	rm -f luaclib/*.so

cleanall: clean
	cd 3rd/lua-cjson && make clean
	cd 3rd/lua-rax && make clean
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
