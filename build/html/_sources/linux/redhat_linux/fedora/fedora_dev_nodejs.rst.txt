.. _fedora_dev_nodejs:

==========================
Fedora环境开发Node.js应用
==========================

从Fedora 24开始，系统默认已经安装了 Node.js 软件包，所以不需要单独安装。如果系统没有安装，则执行以下命令安装::

   sudo dnf install nodejs

上述命令将安装 V8 Javascript引擎，Node.js runtime 以及 npm 包管理器。通常系统默认安装是current 或 LTS 版本。

可选版本
============

Fedora发行版提供了多个可用模块版本，可以通过以下命令查看::

   dnf module list

输出显示::

   ...
   nodejs   12   default [d], development, minimal   Javascript runtime
   nodejs   14   default, development, minimal       Javascript runtime
   nodejs   15   default, development, minimal       Javascript runtime
   nodejs   16   default, development, minimal       Javascript runtime
   ...

则可以指定版本安装::

   sudo dnf module install nodejs:12

nvm管理多版本
=====================

Node Version Manager (nvm)可以在系统中维护多个node.js版本，请参考 :ref:`nodejs_dev_env`

Yarn管理多版本
================

从 Fedora 29 开始提供 Yarn 包管理器，可以通过以下方式安装运行::

   sudo dnf install yarnpkg

- 然后安装需要的包 (这里假设包名字是 ``request`` )::

   yarnpkg add request
   yarn add request

参考
=======

- `Fedora developer Node.js <https://developer.fedoraproject.org/tech/languages/nodejs/nodejs.html>`_
