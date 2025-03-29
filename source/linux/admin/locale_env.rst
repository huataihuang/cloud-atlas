.. _locale_env:

=======================
Linux环境的本地化配置
=======================

我在部署 :ref:`edge_pi_os` 遇到默认环境是UK以及莫名的locale配置导致 ``raspi-config`` 工具界面设置混乱问题。这使得我发现，平时我们忽视的 Linux ``locale`` 环境设置，其实影响到应用程序的交互显示，以及键盘输入布局等设置。本文尝试做一些梳理。

.. note::

   其实后来我发现，原来是不小心配置了 ``/etc/locale.gen`` 中激活了::

      es_US.UTF-8 UTF-8

   ``es_US`` 是 ``Spanish, U.S.A.`` (美国西班牙)，所以导致系统显示出我不认识的字符(西班牙语)。而我本意是设置 ``en_US.UTF-8`` (美式英语)

环境变量优先级
===============

``locale`` 环境变量告诉操作系统如何显示或输出文本，这些环境变量有优先级::

   LANGUAGE
   LC_ALL
   LC_xxx
   LANG

例如，可以使用 ``LANG`` 变量设置 ``French`` 字符集作为语言，但是通过 ``LC_TIME`` 设置美国时间格式。

Locale环境变量
================

要设置某国的本地化支持，必须首先 ``locale-gen`` 对应的本地化。举例，要支持 ``ro_RO.UTF-8 UTF-8`` ，首先需要编辑 ``/etc/locale.gen`` 配置，使得以下行配置生效::

   # ro_RO.UTF-8 UTF-8
   ro_RO.UTF-8 UTF-8

然后执行::

   sudo locale-gen

然后才能设置使用 ``ro_RO.UTF-8`` 作为变量，否则执行 ``export LC_TIME=ro_RO.UTF-8`` 会提示报错::

   -bash: warning: setlocale: LC_TIME: cannot change locale (ro_RO.UTF-8): No such file or directory

- 使用 ``locale`` 命令可以显示当前环境变量设置，例如::

   LANG=en_US.UTF-8
   LANGUAGE=en_US
   LC_CTYPE="en_US.UTF-8"
   LC_NUMERIC=ro_RO.UTF-8
   LC_TIME=ro_RO.UTF-8
   LC_COLLATE="en_US.UTF-8"
   LC_MONETARY=ro_RO.UTF-8
   LC_MESSAGES="en_US.UTF-8"
   LC_PAPER=ro_RO.UTF-8
   LC_NAME=ro_RO.UTF-8
   LC_ADDRESS=ro_RO.UTF-8
   LC_TELEPHONE=ro_RO.UTF-8
   LC_MEASUREMENT=ro_RO.UTF-8
   LC_IDENTIFICATION=ro_RO.UTF-8
   LC_ALL=

``LANG`` 变量
---------------

``LANG`` 环境变量处理Linux系统的语言，Linux系统会按照这个变量设置来输出系统消息。如果这个语言变量没有设置，或者某个消息没有被翻译成这个指定语言，则默认是英语。

``LC_xxx`` 变量
----------------

- ``LC_TIME`` 设置时钟显示格式，例如::

   export LC_TIME=ro_RO.UTF-8

然后执行 ``date`` 就会看到::

   miercuri 9 februarie 2022, 15:27:06 +0800

也可以恢复到US时钟显示格式::

   export LC_TIME=en_US.UTF-8

此时再次执行 ``date`` 显示::

   Wed 09 Feb 2022 03:28:13 PM CST

``LC_MESSAGES``
------------------

``LC_MESSAGES`` 设置打印输出消息的语言，类似于 ``LANG`` ，但是可以设置不同的变量::

   $ locale | grep -w LANG
   LANG=en_US.UTF-8
   $ export LC_MESSAGES=de_DE.UTF-8

则此时输出语言是德语

其他本地化变量:

- ``LC_NUMERIC`` 本地化数字格式

``LC_ALL``
------------

``LC_ALL`` 是一个最强硬本地化变量，除了 ``LANGUAGE`` 以外，会覆盖所有其他变量，并且是操作系统首先检查的本地化设置。

举例::

   export LC_ALL=en_EN.UTF-8

.. note::

   如果设置 ``LC_ALL=C`` 则字符排序会按照 ASCII 码进行

键盘布局
===========

:ref:`raspberry_pi_os` 是debian操作系统，键盘布局配置位于 ``/etc/default/keyboard`` ::

   XKBMODEL="pc105"
   XKBLAYOUT="us"
   XKBVARIANT=""
   XKBOPTIONS=""
   BACKSPACE="guess"

上述配置适合大多数我们常用的键盘布局 - 美式键盘布局

参考
=====

- `Locale Environment Variables in Linux <https://www.baeldung.com/linux/locale-environment-variables>`_
- `How to Change the Keyboard Layout on Raspberry Pi <https://www.makeuseof.com/change-keyboard-layout-raspberry-pi/>`_
