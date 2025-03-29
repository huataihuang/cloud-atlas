.. _gluster_volume_top:

==========================
gluster volume top 命令
==========================

``gluster volume top`` 命令可用于检查 glustefs brick 的性能 :ref:`metrics` ，例如 读，写，文件打开调用，文件读取调用，文件写入调用，目录打开调用，以及目录读取调用。这个 ``top`` 命令最多可以显示100个结果。

``gluster volume top`` 语法:

.. literalinclude:: gluster_volume_top/cmd_format
   :caption: ``gluster volume top`` 语法

简单来说:

- 首先是命令 ``gluster volume top``
- 然后是指定卷名 ``<VOLNAME>`` ，卷名必须提供，也就是说只能针对一个指定卷检查
- ``{open|read|write|opendir|readdir|clear}`` 表示我们每次可以观察一个指令角度，例如:

  - ``open`` 表示显示打开的文件(清单和计数)
  - ``read`` 表示读取的文件
  - 依次类推

- ``[nfs|brick <brick>]`` 表示可以查看GlusterFS的NFS输出，或者直接查看 ``brick`` ，注意 ``brick`` 参数后面必须提供实际的 ``<brick>`` 名字
- ``[list-cnt <value>]`` 表示 ``top`` 命令最多输出多少行记录，也就是 ``top ... list-cnt 10`` 表示输出最高的10条记录(后面就省略不输出了)

查看打开的文件句柄(fd)数量以及最大fd计数
==========================================

可以查看 ``brick`` 上当前打开的文件句柄数量(也就是当前打开的文件列表以及计数)，以及最大打开 ``fd`` 计数(从服务器启动运行开始到当前时间点的最大值)。如果没有指定 ``brick`` ，就会显示所有brick的卷:

- 检查 brick ``192.168.1.80:/data/books`` 读取最多的 ``10`` 个文件:

.. literalinclude:: gluster_volume_top/read_brick_10
   :caption: 显示输出指定brick读取最多的10个文件

此时输出内容可以看到只显示前10的读取最多的文件:

.. literalinclude:: gluster_volume_top/read_brick_10_output
   :caption: 显示输出指定brick读取最多的10个文件
   :emphasize-lines: 4

可以看到访问最多的是 ``mqat.ini`` 配置文件

参考
=======

- `Running GlusterFS Volume TOP Command <https://docs.gluster.org/en/v3/Administrator%20Guide/Monitoring%20Workload/#running-glusterfs-volume-top-command>`_
