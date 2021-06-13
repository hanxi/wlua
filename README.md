# wlua
wlua is a web framework for Lua that is as simple as it is powerful.

```lua
local wlua = require "wlua"
local app = wlua:default()

app:get("/", function (c)
    c:send("Hello wlua!")
end)

app:run()
```

## Installation

### Dependent library

Build [libr3](https://github.com/hanxi/lua-r3) need this library:

```bash
# Ubuntu
sudo apt-get install check libpcre3 libpcre3-dev build-essential libtool \
    automake autoconf pkg-config
# CentOS 7
sodu yum install gcc gcc-c++ git make automake autoconf pcre pcre-devel \
    libtool pkgconfig
```

Build [skynet](https://github.com/cloudwu/skynet/wiki/Build) need `gcc 4.9+` .

Then install use this commond:

```bash
git clone https://github.com/hanxi/wlua
cd wlua
sudo make install
```

`WLUA_HOME` and `WLUA_BIN` are supported by Makefile, so the following command could be used to customize installation, default `WLUA_HOME` is `/usr/local/wlua` and `WLUA_BIN` is `/usr/local/bin/wlua` :

```bash
make install WLUA_HOME=/usr/local/wlua WLUA_BIN=/usr/local/bin/wlua
```

## Features

- Routing use [r3](https://github.com/hanxi/lua-r3)
- Middleware support
- Group router support
- Easy to build HTTP APIs, web site, or single page applications


## Quick Start
A quick way to get started with wlua is to utilize the executable cli tool `wlua` to generate an scaffold application.

`wlua` commond is installed with wlua framework. it looks like:

```bash
$ wlua help
wlua 0.01, a web framework for Lua that is as simple as it is powerful.

Usage: wlua COMMAND [OPTIONS]

Commands:
 new <name>    Create a new application
 start         Start the server
 stop          Stop the server
 reload        Reload the server
 version       Show version of wlua
 help          Show help tips
```

Create app:

```bash
$ wlua new wlua_demo
```

Start server:

```
$ cd wlua_demo
$ wlua start
```

Visit <http://localhost:8081> . Or use `curl` test:

```bash
curl -i http://localhost:8081
```

More test in demo: <https://github.com/hanxi/wlua_demo>

More page in blog: <http://blog.hanxi.cc/p/74/>

