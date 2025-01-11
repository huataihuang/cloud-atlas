.. _xbar:

=============
xbar
=============

`xbar Plugins <https://github.com/matryer/xbar-plugins>`_ 可以将任何脚本或程序的输出加入到macOS menu bar

安装 ``xbar`` 之后，运行后在菜单条上增加 ``xbar`` 菜单，这个菜单可以包含特定插件脚本运行入口:

当前 `xbar Plugins <https://github.com/matryer/xbar-plugins>`_ 官方发布 ``v2.17-beta`` 版本，提供了 ``.dmg`` 安装包，直接运行安装。

点击 ``xbar`` 下拉菜单，从 ``plugin browser...`` 可以找寻自己插件

xbar工作原理
===============

``xbar`` 使用 :ref:`golang` 编写 :ref:`wails` 应用程序

插件API
---------

要编写插件，哪怕是脚本，只要输出格式是标准输出就可以:

- 多行将反复循环
- 如果输出包含仅由 ``---`` 组成的行，那么 ``---`` 下方的行将出现在该插件的下拉列表中，但不会出现在菜单栏本身中
- 以 ``--`` 开狗的行将出现在子菜单
- 对于嵌套子菜单，则使用 ``----`` ，每个嵌套界别使用两个 ``-``
- 行里面包含 ``|`` 将标题和其他参数分开

``xbar`` 支持多种语言编写脚本，包括 :ref:`ruby` , :ref:`python` , :ref:`javascript` ( :ref:`nodejs` / ``deno`` ), :ref:`swift` , :ref:`golang` , Lisp, Perl5, PHP

.. note::

   待实践学习

.. _lima-xbar-plugin:

lima-xbar-plugin
====================

我的案例是使用 :ref:`lima` 的一个管理插件 `lima-xbar-plugin(管理lima) <https://github.com/unixorn/lima-xbar-plugin>`_ 

- 下载插件文件 ``lima-xbar-plugin-1.4.0.tar.gz`` ，解压缩，目录下有一个执行文件 ``lima-plugin`` 复制到 ``~/Library/Application\ Support/xbar/plugins/`` 目录下，命名为 ``lima-plugin.10s`` (这个后缀名表示默认theme):

.. literalinclude:: xbar/lima-plugin
   :caption: 安装 ``lima-xbar-plugin`` 插件

- 然后点击 ``xbar`` 的 ``Refresh All`` 菜单，就能够看到该插件生效，能够展示当前运行的 :ref:`lima` 虚拟机

参考
========

- `xbar Plugins <https://github.com/matryer/xbar-plugins>`_
