.. _alpine_init:

====================
Alpine Linux初始化
====================

目前我在iPad上使用 :ref:`ish` 作为终端，尝试不使用电脑仅使用iPad来实现移动工作。iSH本质上是 :ref:`qemu` 运行 Alpine Linux，并且是最小化的 ``Mini Root Filesystem`` ，所以安装以后需要做一些初始化工作以方便进一步使用。

创建用户账号
===============

:ref:`ish` 使用了Alpine Linux的 ``Mini Root Filesystem`` 版本（一个非常微小的系统打包)，默认只有 ``root`` 用户账号，所以执行以下命令创建 ``admin`` 账号:

.. literalinclude:: alpine_init/adduser
   :caption: 添加 ``admin`` 账号

安装应用
===========

- :ref:`alpine_apk` 安装一些必要的 :ref:`devops` 应用:

.. literalinclude:: alpine_init/apk_devops
   :caption: 安装devops需要的一些工具应用
