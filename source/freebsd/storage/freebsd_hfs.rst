.. _freebsd_hfs:

====================
FreeBSD HFS+
====================

FreeBSD支持 :ref:`macos` 的 ``HFS/HFS+`` 文件系统的 **只读访问** ，使用工具 ``filesystems/hfsfuse`` :

- 检查分区

.. literalinclude:: freebsd_hfs/gpart
   :caption: ``gpart show``

输出显示分区2是HTFS

.. literalinclude:: freebsd_hfs/gpart_output
   :caption: ``gpart show`` 显示分区2是HFS
   :emphasize-lines: 5,11

- 安装 HFS/HFS+ 软件包:

.. literalinclude:: freebsd_hfs/install
   :caption: 安装 ``fusefs-hfsfuse``

- 加载内核模块 ``fusefs`` :

.. literalinclude:: freebsd_hfs/kldload
   :caption: 加载内核模块

- 设置 ``sysrc`` 启动时加载内核模块 ``fusefs`` :

.. literalinclude:: freebsd_hfs/sysrc
   :caption: 设置启动时加载内核模块 ``fusefs``
 
- 挂载分区(这里我使用了 ``diskid`` 来标志磁盘分区避免搞错):

.. literalinclude:: freebsd_hfs/mount
   :caption: 挂载HFS分区

参考
======

- `23.4. MacOS® File Systems <https://docs.freebsd.org/en/books/handbook/filesystems/#filesystems-macos>`_
