.. _run_nodejs_web:

====================
运行Nodejs简单WEB
====================

虽然Node自带http模块，但是需要很多套路化开发工作，所以通常WEB开发会使用 :ref:`express` ，以下为快速开启一个 ``later`` 项目(摘自 「Node.js实战」):

.. literalinclude:: run_nodejs_web/init_express
   :language: bash
   :caption: 初始化名为 ``later`` 的项目，通过 ``express`` 构建
   :emphasize-lines: 4

此时生成的 ``package.json`` 添加了 :ref:`express` 模块的依赖::

   "dependencies": {
     "express": "^4.18.2"
   }

如果要卸载 ``express`` 模块则执行::

   npm rm express --save

起步
========

- 编写一个简单的 ``index.js`` :

.. literalinclude:: run_nodejs_web/index.js
   :language: javascript
   :caption: 简单的Hello World

- 虽然可以直接通过 ``node index.js`` 来运行，但是通常我们会修订 ``package.json`` 增加运行参数如下

.. literalinclude:: run_nodejs_web/package.json
   :language: json
   :caption: package.json增加了express模块，并添加启动运行命令 start 对应的脚本命令
   :emphasize-lines: 7,13-15

- 现在执行 ``npm start`` 就相当于运行了 ``node index.js`` ，然后可以看到控制台输出::

   > later@1.0.0 start
   > node index.js

   Express web app available at localhost: 3000

此时浏览器访问 http://localhost:3000

就会看到熟悉的 ``Hello World``

参考
=======

- 「Node.js实战」- 第三章节
