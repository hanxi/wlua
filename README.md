# wlua

[![GitHub actions](https://github.com/hanxi/wlua/actions/workflows/docker-publish.yml/badge.svg?branch=main)](https://github.com/hanxi/wlua/actions)
[![GitHub release](https://img.shields.io/github/release/hanxi/wlua.svg)](https://github.com/hanxi/wlua/releases/latest)
[![license](https://img.shields.io/github/license/hanxi/wlua.svg)](https://github.com/hanxi/wlua/blob/master/LICENSE)

<a href="./README_zh.md" style="font-size:13px">中文</a> <a href="./README.md" style="font-size:13px">English</a>

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

So, need `/usr/local/bin` in `$PATH` .

## Features

- Routing use [lua-rax]
- Middleware support
- Group router support
- Easy to build HTTP APIs, web site, or single page applications


## Quick Start
A quick way to get started with wlua is to utilize the executable cli tool `wlua` to generate an scaffold application.

`wlua` commond is installed with wlua framework. it looks like:

```bash
$ wlua help
wlua 0.0.2, a web framework for Lua that is as simple as it is powerful.

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

## API Examples

More examples in [wlua-examples](https://github.com/hanxi/wlua-examples)

### Using GET, POST, PUT, PATCH, DELETE and OPTIONS

```lua
local wlua = require "wlua"

-- Creates a wlua router with default logger middleware.
local app = wlua:default()

app:get("/someget", function (c)
    c:send("someget")
end)

app:post("/somepost", function (c)
    c:send("somepost")
end)

app:put("/someput", function (c)
    c:send("someput")
end)

app:delete("/somedelete", function (c)
    c:send("somedelete")
end)

app:patch("/somepatch", function (c)
    c:send("somepatch")
end)

app:head("/somehead", function (c)
    c:send("somehead")
end)

app:options("/someoptions", function (c)
    c:send("someoptions")
end)

-- By default it serves on :8081
app:run()
```

### Parameters in path

### Querystring parameters

### Urlencoded Form

### Another example: query + post form

### Post JSON

### Upload files

### Grouping routes

### Blank Wlua without middleware by default

### Using middleware

### JSON rendering

### Serving static files

### Serving data from file

### Custom Middleware

### Graceful shutdown or reload

### Set and get a cookie

### origin skynet service

use skynet service_provider create uniqservice

#### timer task

## Other

- More test in demo: <https://github.com/hanxi/wlua-demo>
- More page in blog: <http://blog.hanxi.cc/p/74/>
- A tools for monitor skyent cluster <https://github.com/hanxi/skynet-admin>

[lua-rax]: https://github.com/hanxi/lua-rax
