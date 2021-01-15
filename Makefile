
check:
	luacheck `find . -name '*.lua' '!' -path './skynet/*' | xargs` --ignore 212/self
