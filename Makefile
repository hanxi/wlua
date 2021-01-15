.PHONY: check 3rd

all: 3rd check

3rd:
	cd 3rd/lua-cjson && $(MAKE) install PREFIX=../../skynet/3rd/lua DESTDIR=../.. LUA_CMODULE_DIR=./luaclib

clean:
	rm -f luaclib/*.so

check:
	luacheck `find . -name '*.lua' '!' -path './skynet/*' '!' -path './3rd/*' | xargs` --ignore 212/self

