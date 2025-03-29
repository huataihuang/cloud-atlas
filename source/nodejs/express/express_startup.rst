.. _express_startup:

===================
Express 快速起步
===================

简单的Hello
=============

- 确保已经完成 :ref:`nodejs` 安装，现在创建目录(myapp)来保存应用(假设应用名是 ``myapp`` ):

.. literalinclude:: express_startup/myapp
   :caption: 创建项目目录

- 在目录下创建一个简单的 ``index.js`` :

.. literalinclude:: express_startup/index.js
   :caption: ``index.js``

- **一种方式是** : 执行 ``npm install express@4`` 安装 Express 4系列，执行以后，目录下会生成 ``package.json`` 内容非常简单:

.. literalinclude:: express_startup/package_simple.json
   :caption: 非常简单的 ``package.json``

- 现在可以运行 ``index.js`` 了:

.. literalinclude:: express_startup/node_index
   :caption: 执行 ``index.js``

输出非常简单:

.. literalinclude:: express_startup/node_index_output
   :caption: 执行 ``index.js`` 终端输出

此时用浏览器访问 http://127.0.0.1:3000 会提示 ``Cannot GET /`` ，但是可以注意到这个简单 ``index.js`` 实际上是提供了 ``/hello`` 入口，所以应该访问 http://127.0.0.1:3000/hello ，就能够看到网页输出 ``Hello World!`` ::

   get 请求 /hello => res 返回 Hello World!

交互方式创建项目
==================

- **另一种方式是** : 执行 ``npm init`` 在程序目录下生成一个 ``package.json`` 文件(这是一个交互过程，根据交互内容生成配置)

生成的 ``package.json`` 内容类似如下:

.. literalinclude:: express_startup/package.json
   :language: json
   :caption: 通过 ``npm init`` 生成一个初始化 ``package.json`` 的内容
   :emphasize-lines: 5

其中主要的就是 ``index.js`` 作为主文件

- 安装 Express:

.. literalinclude:: express_startup/install_express
   :caption: 安装Express

完成Express安装以后，目录下的 ``package.json`` 会修订添加 ``dependencies`` 部分:

.. literalinclude:: express_startup/package_express.json
   :language: json
   :caption: 安装了Express之后 ``package.json`` 配置
   :emphasize-lines: 11-13

此时目录下还有一个 ``package-lock.json`` 是自动生成的，是为了解决依赖的详细版本要求

快速脚手架
===============

- 全局安装npm包 ``express-generator`` ，然后创建应用（使用的 view engine 是 ``Pug`` ):

.. literalinclude:: express_startup/install_express-generator
   :caption: 全局安装 ``express-generator``

- 有了 ``express-generator`` 就能快速建立 ``myapp`` 应用脚手架:

.. literalinclude:: express_startup/express-generator
   :caption: 生成脚手架

此时输出信息显示自动创建了程序目录及相关文件:

.. literalinclude:: express_startup/express-generator_output
   :caption: 生成脚手架输出信息

- 进入目录安装依赖:

.. literalinclude:: express_startup/install
   :caption: 安装依赖

可能会提示存在漏洞，按照提示使用 ``npm audit fix --force`` 修复

- 运行:

.. literalinclude:: express_startup/run
   :caption: 运行

``npx`` 一次性执行脚本
========================

在安装了 Node.js 之后，同时也具备了 ``npx`` 。这个工具可以从仓库执行任何软件包而无需安装。这主要是用于测试一些一次性代码，例如使用脚手架脚本来初始化项目，但既不是依赖项也不是开发依赖项。

参考
=======

- `Express Getting Started: Installing <https://expressjs.com/en/starter/installing.html>`_
