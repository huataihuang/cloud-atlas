.. _webssh:

===============
WebSSH
===============

`GitHub: huashengdun/webssh <https://github.com/huashengdun/webssh>`_ 是一个基于 tornado, paramiko 和 :ref:`xtermjs` 的简单Web SSH终端，可以方便连接到 :ref:`ssh` 服务器进行维护。

我使用WebSSH的目的是在 :ref:`termux` 中运行一个能够支持中文输入的终端模拟器。虽然 :ref:`termux` 本身就是一个终端，但是在Android上，终端模拟器输入中文是一个非常痛苦(低效)的操作，我就考虑在浏览器中使用终端，以便能够借助 ``chrome`` 较好的平台支持输入法来实现日常的 :ref:`mobile_work` 。

准备工作
==========

.. note::

   我的这个实践是在 :ref:`termux` (Android上的一个终端)中完成，所以环境和常规的 :ref:`linux` 不同，出现的问题和解决方法和特定平台相关。

- 安装 :ref:`rust` , :ref:`clang` 编译环境(我尝试 ``pip install webssh`` 提示报错需要Rust compiler): (采用 :ref:`termux_dev` 方法):

.. literalinclude:: webssh/install_build_env
   :caption: 在 :ref:`termux` 中安装必要编译工具环境

安装
=======

- 通过 :ref:`virtualenv` 准备 :ref:`python` 运行环境:

.. literalinclude:: ../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

.. literalinclude:: ../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

- ``pip`` 安装 ``webssh`` :

.. literalinclude:: webssh/install_webssh
   :caption: ``pip`` 安装 ``webssh``

运行
======

- 直接运行:

.. literalinclude:: webssh/wssh
   :caption: 没有任何参数运行 ``wssh``

此时输出信息提示默认绑定 ``127.0.0.1:8888`` ，所以通过本机可以直接浏览器访问

- 常用运行:

.. literalinclude:: webssh/wssh_run
   :caption: 常用参数运行 ``wssh``
   :language: bash

部署
=======

WebSSH可以部署在 :ref:`nginx` 后端，通过 :ref:`nginx_reverse_proxy` 访问

``尚未实践``

- 运行:

.. literalinclude:: webssh/run_behind_nginx
   :caption: 在 :ref:`nginx` 后运行 WebSSH

- 配置nginx案例:

.. literalinclude:: webssh/nginx.conf
   :caption: 配置nginx

- 作为独立服务器运行:

.. literalinclude:: webssh/run_as_standalone_server
   :caption: 作为独立服务器运行

参考
========

- `GitHub: huashengdun/webssh <https://github.com/huashengdun/webssh>`_
