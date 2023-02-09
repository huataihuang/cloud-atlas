.. _nodejs_basic:

===================
Node.js基础
===================

.. note::

   Node.js 的基础就是 :ref:`javascript` ，在官方文档 `How much JavaScript do you need to know to use Node.js? <https://nodejs.dev/zh-cn/learn/how-much-javascript-do-you-need-to-know-to-use-nodejs/>`_ 对需要掌握的JavaScript的知识点进行了列举，可以按照这个索引阅读Mozilla官方的JavaScript教程

- 初始化node:

.. literalinclude:: nodejs_basic/node_init
   :language: bash
   :caption: node初始化

初始化后在当前目录会创建一个 ``package.json`` 

创建模块
==========

Node以同步方式寻找模块，定位到模块并加载模块文件中内容。Node查找文件的顺序是先找核心模块，然后是当前目录，最后是 ``node_modules`` 目录

参考
======

- 「Node.js实战」- 第二章节没有循序渐进，让我很挠头，改为阅读node.js官方文档学习
