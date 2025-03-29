.. _uninstall_asahi_linux:

======================
卸载Asahi Linux
======================

由于实在没有时间折腾桌面，也由于一些客观原因，我暂时放弃继续在Macbook M1笔记本上使用Linux:

- 需要集中精力在 :ref:`kubernetes` 和 :ref:`machine_learning`
- 工作中太多需要依赖商业软件(我厂的那些一言难尽的办公软件)

所以我通过以下方式抹去Asahi Linux:

.. literalinclude:: uninstall_asahi_linux/wipe_asahi_linux
   :caption: 卸载 Asahi Linux 只需要一条命令(使用 ``root`` 执行)

需要翻墙执行(否则脚本下载会超时)，执行结果输出:

.. literalinclude:: uninstall_asahi_linux/wipe_asahi_linux_output
   :caption: 卸载 Asahi Linux 的输出信息
   :emphasize-lines: 49,50

根据官方FAQ，可以忽略最后的 ``operation not permitted`` 错误(或者在recovery模式下执行)

完成后，使用 macOS 的 ``Disk Utility`` 检查可以看到 Asahi Linux 的分区被完全抹去(全部显示为 ``free space`` )，此时就可以使用 ``Disk Utility`` 将macOS分区扩展到全部磁盘，恢复最初的macOS使用状态

参考
=====

- `Partitioning cheatsheet <https://github.com/AsahiLinux/docs/wiki/Partitioning-cheatsheet>`_ Asahi Linux官方GigHub提供了有关如何抹去Asahi Linux的分区方法
- `How to uninstall? <https://www.reddit.com/r/AsahiLinux/comments/vs4qp1/how_to_uninstall/>`_
