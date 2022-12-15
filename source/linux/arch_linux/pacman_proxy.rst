.. _pacman_proxy:

=======================
pacman使用代理服务器
=======================

:ref:`pacman` 可以配置使用外部下载工具，在 ``/etc/pacman.conf`` 中有如下2行分别使用 :ref:`curl` 和 :ref:`wget` 来实现下载的配置行::

   #XferCommand = /usr/bin/curl -L -C - -f -o %o %u
   #XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u

取消其中一行注释，然后分别配置 :ref:`curl` 或 :ref:`wget` 的代理，就能够实现 :ref:`pacman` 通过代理下载。

简单配置proxy
================

- 在环境变量中执行:

.. literalinclude:: pacman_proxy/pacman_proxy_env
   :language: bash
   :caption: 设置pacman代理的环境变量

我已经实践，简单采用上述环境变量就能够让 :ref:`pacman` 使用代理服务器下载软件包

参考
=======

- `Gettin pacman to work through proxy with Wget <https://www.puppychau.com/archives/667>`_
