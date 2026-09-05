.. _opencore_macos_basesystem_install:

=======================================
OpenCore采用macOS BaseSystem安装
=======================================

除了先下载一个完整的macOS安装程序，并使用 :ref:`create_boot_usb_from_iso_in_mac` 方法创建本地安装U盘来安装黑苹果之外。还有一种通过BaseSystem.img来启动，通过网络安装最新macOS系统。好处是不用在开始时就下载完整安装镜像，而且现在下载镜像也比较折腾，不如就通过网络方式安装。

当然，OpenCore的UEFI System分区构建还是需要按照 :ref:`c246_mi50_hackintosh` 方式完成，本文步骤的关键是下载 ``BaseSystem.img`` 并按照规范存放到OpenCore制作的启动U盘。

下载
======

OpenCore软件包中提供了一个工具 ``macrecovery`` 位于 ``Utilities/macrecovery`` 目录下，在该目录下有一个 ``recovery_urls.txt`` 针对每个不同的macOS版本提供了相应的命令说明:

.. literalinclude:: opencore_macos_basesystem_install/macrecovery
   :caption: 执行recovery_urls.txt中提供的针对不同版本macOS下载命令

如果一切正常，并且最后checksum也检查正确，那么就会在当前目录的 ``com.apple.recovery.boot`` 子目录下存放了 ``BaseSystem.dmg``

.. note::

   如果下载过程有中断，可能需要删除掉 ``com.apple.recovery.boot`` 目录然后重新下载，否则会一直报下载镜像checksum错误。

文件存放
==========

在U盘的数据分区中创建一个 ``com.apple.recovery.boot`` 目录，然后将下载的 ``BaseSystem.dmg`` 和 ``BaseSystem.chunklist`` 存放进去 

参考
======

- gemini
