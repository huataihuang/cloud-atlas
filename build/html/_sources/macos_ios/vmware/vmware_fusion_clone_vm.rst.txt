.. _vmware_fusion_clone_vm:

==========================
VMware Fusion clone虚拟机
==========================

使用 :ref:`macos_vmware` 时，如果安装了基础操作系统并更新了最新的软件包，往往想要把这个虚拟机保存下来作为基础模版。此时我们可以备份虚拟机，或者从模版虚拟机中clone出来新的虚拟机用于测试和开发。

.. note::

   必需在虚拟机关机情况下备份整个虚拟机，备份方法就是复制 ``.vmwarevm`` 包（Virtual Machines文件夹中的对象）

-  关闭虚拟机

找到虚拟机捆绑包：捆绑包是一系列文件组成的包，包括虚拟机的磁盘（数据）和配置文件。默认虚拟机捆绑包位于 ``Macintosh HD/Users/User_name/Documents/Virtual Machines`` (参考 `在 VMware Fusion 中查找虚拟机捆绑包 (1007599) <https://kb.vmware.com/s/article/1007599?lang=zh_CN>`_ )

-  按住 ``option`` 键拖放捆绑包，表示复制文件，这样macOS就会复制捆绑包奥。

.. note::

   在使用了APFS文件系统的macOS中，使用 ``option`` 键拖放复制可以实现秒速复制，实际上是copy-on-write，可以极大节约磁盘消耗。（不过，在终端中使用 ``cp -R`` 命令是实际复制，暂时没有找到命令行方案）

-  然后使用VMware Fusion打开这个新虚拟机，此时Fusion会询问是否已经移动或复制该虚拟机。选择 ``已移动该虚拟机`` ，则表示该虚拟机从新位置启动同一个虚拟机，所有设置不便。如果选择 ``已复制该虚拟机`` ，将生成新的 UUID 和 MAC 地址，这可导致 Windows 需要重新激活，还可能会导致出现网络问题。

VMware Fusion Pro版本支持链接clone虚拟机，实际测试发现确实能够大大节约磁盘空间消耗。

参考
======

-  `在 VMware Fusion 中复制虚拟机 (1001524) <https://kb.vmware.com/s/article/1001524?lang=zh_CN>`_
