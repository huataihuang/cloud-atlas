.. _blfs_linux-tools:

========================
BLFS linux-tools
========================

Linux内核有一些很重要和有用的工具，需要从内核源代码中编译安装。这里我选择我所使用到的部分工具进行安装

cpupower
==============

调整 :ref:`cpu_frequency_governor` 会使用到 ``cpupower``

.. literalinclude:: blfs_linux-tools/cpupower
   :caption: 安装 ``cpupower``

安装的库文件会安装到 ``/usr/lib64`` 目录下，这个目录没有在 ``/etc/ld.so.conf`` 配置中，会导致 ``cpupower frequency-info`` 执行时报错:

.. literalinclude:: blfs_linux-tools/libcpupower.so
   :caption: 执行时找不到库文件 ``libcpupower.so.1``

解决方法是添加 ``ld.so.conf`` 配置:

.. literalinclude:: blfs_linux-tools/ldconfig
   :caption: 配置ld
