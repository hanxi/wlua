# 介绍

## wlua 是什么

wlua 是一个运行在 [skynet] 上的使用 Lua 编写的 Web 框架。 它兼顾开发效率和运行时性能， 可用于快速开发 API Server。

## 特性

- 路由采用 [gin] 风格，结构清晰，易于编码和维护
- 支持 middleware 机制，可在任意路由上挂载中间件
- 支持多种路由，路由可分组
- 可作为HTTP API Server，也可用于构建 VUE 类应用

## 最简示例

```lua
local wlua = require "wlua"
local app = wlua:default()

app:get("/", function (c)
    c:send("Hello wlua!")
end)

app:run()
```

## 安装

### 依赖库

编译 [libr3] 需要下面这些库:

```bash
# Ubuntu
sudo apt-get install check libpcre3 libpcre3-dev build-essential libtool \
    automake autoconf pkg-config
# CentOS 7
sodu yum install gcc gcc-c++ git make automake autoconf pcre pcre-devel \
    libtool pkgconfig
```

编译 [skynet] 需要 gcc 4.9+ 版本.

然后用下面的命令编译 [wlua]:

```bash
git clone https://github.com/hanxi/wlua
cd wlua
sudo make install
```

`WLUA_HOME` 和 `WLUA_BIN` 可以在 Makefile 设置, 所以可以用下面的命令自定义安装目录(默认的 `WLUA_HOME` 为 `/usr/local/wlua` , `WLUA_BIN` 为 `/usr/local/bin/wlua` ):

```bash
make install WLUA_HOME=/usr/local/wlua WLUA_BIN=/usr/local/bin/wlua
```

## 快速开始

开始使用 wlua 的一种快速方法是利用可执行的 cli 工具 wlua 来生成脚手架应用程序。

`wlua` 命令 与 wlua 框架一起安装。运行查看帮助：

```txt
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

以 wlua_demo 为名字新创建一个工程:

```bash
$ wlua new wlua_demo
```

开启服务:

```bash
$ cd wlua_demo
$ wlua start
```

使用浏览器进入 <http://localhost:8081> 查看效果. 或者使用 curl 命令查看效果:

```bash
$ curl -i http://localhost:8081
```

## API 示例

### Using GET, POST, PUT, PATCH, DELETE and OPTIONS

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

## 示例项目

- [wlua-demo] wlua 示例项目，配合 [vue-admin-template] 制作的后台模板
- [skynet-admin] skynet 管理后台，深度集成 skynet cluster 集群管理

[skynet]: https://github.com/cloudwu/skynet
[gin]: https://github.com/gin-gonic/gin
[wlua-demo]: https://github.com/hanxi/wlua-demo
[vue-admin-template]: https://github.com/PanJiaChen/vue-admin-template
[skynet-admin]: https://github.com/hanxi/skynet-admin

