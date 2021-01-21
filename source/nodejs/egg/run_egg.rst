.. _run_egg:

===============
运行Egg.js
===============

快速初始化Egg
==============

- 直接使用脚手架生成项目::

   mkdir egg-example && cd egg-example
   npm init egg --type=simple
   npm i

安装npm会提示一些安全信息或者patch信息，例如提示你升级npm ``npm install -g npm`` ，以及修复漏洞 ``npm audit fix``

- 启动项目::

   npm run dev
   open http://localhost:7001

初始化项目
============

- 按照以下步骤初始化目录结构::

   mkdir egg-example
   cd egg-example
   npm init
   npm i egg --save
   npm i egg-bin --save-dev

参考
======

- `Egg快速入门 <https://eggjs.org/zh-cn/intro/quickstart.html>`_
