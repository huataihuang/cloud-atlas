.. _run_nodejs:

===================
运行Node.js
===================

对于Linux操作系统，通过发行版包管理器安装Node.js最为方便，包括Debian/Ubuntu, Fedora/CentOS/RHEL 都提供了安装包。

Linux安装Node.js
=================

- Fedora::

   sudo dnf install nodejs

- Ubuntu::

   sudo apt install nodejs

macOS安装Node.js
====================

- macOS从Nodejs官网下载pkg进行安装，非常简单

- 另一种方式是使用 :ref:`homebrew` 安装::

   brew install node

卸载Node
---------

- 通过brew安装的node可以如下卸载::

   brew uninstall node; 
   # or `brew uninstall --force node` which removes all versions
   brew cleanup;
   rm -f /usr/local/bin/npm /usr/local/lib/dtrace/node.d;
   rm -rf ~/.npm;

- 使用官方pkg安装包，则使用如下命令卸载::

   cd /
   lsbom -f -l -s -pf /var/db/receipts/org.nodejs.node.pkg.bom \
   | while read i; do
     sudo rm ${i}
   done
   sudo rm -rf /usr/local/lib/node \
        /usr/local/lib/node_modules \
        /var/db/receipts/org.nodejs.*

.. warning::

   这里删除命令是 ``sudo`` 方式非常危险，所以务必检查 ``lsbom -f -l -s -pf /var/db/receipts/org.nodejs.node.pkg.bom`` 输出内容，确保是删除node相关文件。

验证Node
==========

- 验证node:

创建一个名为 ``hello.js`` 文件内容如下::

   console.log("hello from Node");

保存文件执行 ``node hello.js``

npm
=====

``npm`` 命令行工具可以用来安装npm注册中心都包，也可以用来查找和分享自己的项目，可以是开源也可以是闭源。注册中心都每个npm包都有一个页面显示它都自述文件、作者和下载统计信息。

npm要求Node项目所在的目录下有个 ``package.json`` 文件，创建这个文件的最简单方法是使用npm::

   mkdir example-project
   cd example-project
   npm init -y

在当前目录下会生成一个 ``package.json`` 可以看到简单的JSON格式项目描述信息。

如果你使用带有 ``--save`` 参数的npm命令从npm网站安装一个包，会自动更新 ``package.json`` 。以下是安装 ``express`` 案例::

   npm install --save express

提示信息::

   npm notice created a lockfile as package-lock.json. You should commit this file.
   npm WARN example-project@1.0.0 No description
   npm WARN example-project@1.0.0 No repository field.

   + express@4.17.1

此时可以看到 ``package.json`` 文件中 ``dependencies`` 属性下新增了 ``express`` ::

   "dependencies": {
     "express": "^4.17.1"
   }

并且 ``node_modules`` 目录下是刚安装的Express。

Node核心模块
================

JavaScript标准本身没有任何处理网络和文件I/O的功能，Node为其增加了文件和TCP/IP网络功能，使JavaScript扩展成了一个服务器端编程语言。

核心模块：

- 文件系统库 fs, path
- TCP客户端和服务器端库 net
- HTTP库 http和https
- 域名解析库 dns
- 用于测试的断言库 assert
- 查询平台信息的操作系统库 os

文件系统和管道
----------------

Node有一些独有库。事件模块是一个处理事件的小型库，Node的大多数API都是以它为基础来做的。例如，流模块用事件模块提供了一个处理数据流的抽象接口。由于Node中所有数据流都使用相同的API，就可以组装成软件组件。如果有一个文件流读取器，就可以把它和压缩数据的zlib连接到一起，然后zlib再链接一个文件流写入器，从而形成一个文件流处理管道，即压缩::

   const fs = require('fs');
   const zlib = require('zlib');
   const gzip = zlib.createGzip();
   const outStream = fs.createWriteStream('output.js.gz');

   fs.createReadStream('./node-stream.js')
     .pipe(gzip)
     .pipe(outStream);

执行上述 ``compact.js`` 就可以压缩一个文件，有点类似shell

网络
------

- 创建或修订 ``hello.js`` 如下:

.. literalinclude:: run_nodejs/hello.js
   :language: javascript
   :caption: 在WEB运行的hello.js

.. note::

   这里采用 Node.js 官方文档 `在安装了 Node.js 之后，我怎么开始呢？ <https://nodejs.org/zh-cn/docs/guides/getting-started-guide/>`_

- 执行命令::

   node hello.js

则会看到终端输出信息就是 ``console.log(`Server running at http://${hostname}:${port}/`);`` ::

   Server running at http://127.0.0.1:3000/

此时用浏览器访问 ``http://localhost:3000`` 就会看到浏览器中显示内容::

   Hello World

调试器
=========

Node自带的调试器支持单步执行和 ``REPL`` ( ``读取-计算-输出-循环`` )::

   node inspect hello.js

此时你会看到终端输出::

   < Debugger listening on ws://127.0.0.1:9229/366f312d-987a-4a78-85c8-efbd5bc4fccf
   < For help, see: https://nodejs.org/en/docs/inspector
   < Debugger attached.
   Break on start in hello.js:1
   > 1 const http = require('http');
     2 const port = 8080
     3
   debug>   

然后停止在 ``break`` 状态。输入 ``help`` 可以查看帮助，输入 ``c`` 让程序继续执行，此时就会显示::

   < Server listening on: http://localhost:8080

在代码的任何地方添加 ``debugger`` 语句就可以设置断点。当遇到 ``debugger`` 语句之后，调试器就会把程序停住，此时你可以输入命令单步执行每条指令，排查程序问题。

三种主流Node程序
==================

Node程序主要分三类:

- Web应用程序，如单页面WEB，REST微服务，全站Web应用
- 命令行工具和后台程序，如npm, Gulp(自动化构建工作流) 和Webpack(前端资源加载/打包工具); 如PM2进程管理器
- 桌面程序，如使用Electron框架编写的桌面软件

Web应用程序案例
------------------

- 创建一个独立目录，然后在目录中安装Express模版，来快速构建一个 Express Web应用程序::

   mkdir hello_express
   cd hello_express
   npm init -y
   npm i express --save

- ``server.js`` 内容::

   const express = require('express');
   const app = express();
   
   app.get('/', (req, res) => {
       res.send('Hello World!');
   });
   
   app.listen(3000, () => {
       console.log('Express web app on localhost:3000');
   });

- 执行启动命令::

   npm start

此时用浏览器访问 http://localhost:3000 可以看到 ``res.send`` 代码发回的文本。

.. note::

   当前Node也是前端开发的语言转译主要工具，例如从TypeScript到JavaScript。转译器可以将一种高级语言编译成另一种高级语言，传统的编译器则将一种高级语言编译成一种低级语言。

命令行工具
-------------

可以用Node来运行命令行工具，例如一些脚本，以下 ``cli.js`` 就是读取终端参数并输出到控制台::

   const [nodePath, scriptPath, name] = process.argv;
   console.log('Hello', name)

Node命令行还可以类似shell脚本，在刚才的 ``cli.js`` 最开头加上::

   #!/usr/bin/env node

然后把 ``cli.js`` 加上执行属性 ``chmod +x cli.js`` ，则我们执行::

   ./cli.js World

可以看到输出::

   Hello World

以上案例展示了Node替代shell脚本的能力，也就是Node可以和其他任何命令行工具配合。

桌面程序
----------

Electron框架使用Node作为后台来访问硬盘和网络::

   git clone https://github.com/electron/electron-quick-start
   cd electron-quick-start
   npm install && npm start
   curl localhost:8081

上述简单的步骤就可以在你的桌面操作系统中运行一个图形界面程序，虽然目前什么都做不了，但是展示了一个桌面应用开发的可能性，后续在此基础上可以进一步开发 :ref:`electron`

.. note::

   传统的模型-视图-控制器(MVC) Web应用，例如 :ref:`ghost_cms` 博客引擎就是使用Node构建的。

参考
======

- `How to Uninstall Node.js from Mac OSX <https://stackabuse.com/how-to-uninstall-node-js-from-mac-osx/>`_
