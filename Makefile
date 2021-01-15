.PHONY: check 3rd

all: 3rd check

3rd:
	cd 3rd/lua-cjson && $(MAKE) install LUA_INCLUDE_DIR=../../skynet/3rd/lua DESTDIR=../.. LUA_CMODULE_DIR=./luaclib CC='$(CC) -std=gnu99'

clean:
	rm -f luaclib/*.so

cleanall: clean
	cd 3rd/lua-cjson && make clean

check:
	luacheck `find . -name '*.lua' '!' -path './skynet/*' '!' -path './3rd/*' | xargs` --ignore 212/self

