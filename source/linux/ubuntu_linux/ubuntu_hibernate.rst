.. _ubuntu_hibernate:

==================================
Ubuntu Hibernate休眠
==================================

从Ubuntu 21.04 开始，需要采用 :ref:`systemd` 结合内核来实现休眠，原先用户端 ``uswsusp`` 已经不再支持。

``systemd-hibernate.service`` 直接激活会提示错误:

.. literalinclude:: ubuntu_hibernate/enable_systemd-hibernate
   :caption: 尝试激活 ``systemd-hibernate.service``

提示报错:

.. literalinclude:: ubuntu_hibernate/enable_systemd-hibernate_error
   :caption: 尝试激活 ``systemd-hibernate.service`` 报错

需要向内核传递swap参数，也就是 ``resume=UUID=`` :

- 当使用 swap 分区时不需要传递 ``resume_offset`` 参数
- 当时用 swap 文件时，则需要参考 :ref:`archlinux_hibernates` 实践中设置传递swap文件的offset参数

准备swap分区
===============

可以使用 swap 分区，也可以使用 swap 文件: 在提供hibernate的磁盘存储上没有本质区别，只是 swap 分区只需要向内核传递 ``resume=UUID=`` 参数指向分区即可；而 swap 文件还需要同时传递一个 ``swap_file_offset`` 参数(见 :ref:`ubuntu_hibernate_old` )。我在这里的实践采用swap分区:

- 分区准备:

.. literalinclude:: ubuntu_hibernate/swap_partition
   :caption: 准备swap分区

- 检查磁盘分区的uuid:

.. literalinclude:: ubuntu_hibernate/blkid
   :caption: 检查sda1的磁盘uuid

显示uuid如下:

.. literalinclude:: ubuntu_hibernate/blkid_output
   :caption: 检查sda1的磁盘uuid

- 对应在 ``/etc/fstab`` 添加swap配置:

.. literalinclude:: ubuntu_hibernate/fstab
   :caption: 在 ``/etc/fstab`` 中添加swap配置

配置内核参数
===============

- 编辑 ``/etc/default/grub`` 添加

.. literalinclude:: ubuntu_hibernate/grub
   :caption: 编辑 ``/etc/default/grub`` 传递hibernate resume参数

- 编辑 ``/etc/initramfs-tools/conf.d/resume``

.. literalinclude:: ubuntu_hibernate/resume
   :caption: 编辑 ``/etc/initramfs-tools/conf.d/resume`` 为 initramfs 传递resume参数

- 重建 ``initramfs`` :

.. literalinclude:: ubuntu_hibernate/update-initramfs
   :caption: 重新生成initramfs

- 重启一次服务器; ``reboot``

- 重启完成后，就可以通过 :ref:`systemd` 来管理hibernate:

.. literalinclude:: ubuntu_hibernate/systemctl_hibernate
   :caption: 通过 :ref:`systemd` 管理 hibernate

当完成hibernate存储运行到磁盘之后，服务器就会断电关机。要重新恢复运行状态，则按下电钮即可，在控制台终端最后会看到一段有关image加载的记录:

.. figure:: ../../_static/linux/ubuntu_linux/hibernage_load.png

   操作系统启动时恢复hibernate存储状态

- 系统恢复以后，可以通过以下命令检查 ``systemd-hibernate`` 服务，可以看到加载是否成功以及出错信息(如果有的话):

.. literalinclude:: ubuntu_hibernate/systemctl_hibernate_status
   :caption: 检查hibernate恢复状态

输出类似如下:

.. literalinclude:: ubuntu_hibernate/systemctl_hibernate_status_output
   :caption: 检查hibernate恢复状态信息输出(多次记录)
   :emphasize-lines: 12-15

非root用户
===========

.. note::

  `How To Enable Hibernation On Ubuntu (When Using A Swap File) <https://www.linuxuprising.com/2021/08/how-to-enable-hibernation-on-ubuntu.html>`_ 还提供了一些非root用户使用hibernate的配置方法，我没有实践。如有需要请参考原文

异常排查
=========

``systemctl hibernate`` 之后，我开启电源，发现服务器确实启动后进行了镜像解压缩，也就是从swap分区中将先前 ``hibernate`` 的内存中状态恢复过来:

.. literalinclude:: ubuntu_hibernate/hibernate_restore_image_load
   :caption: 从 ``hibernage`` 状态恢复时控制台输出信息显示保存在磁盘中的镜像已经完全恢复
   :emphasize-lines: 17,18

但是稍等几秒钟，出现了 :ref:`mce` 错误:

.. literalinclude:: ubuntu_hibernate/hibernate_mce
   :caption: ``hibernage`` 状态恢复后立即出现 :ref:`mce` 错误

此时服务器自动断电，在控制台吐出如下信息:

.. literalinclude:: ubuntu_hibernate/hibernate_mce_power_off
   :caption: ``hibernage`` 恢复时出现 :ref:`mce` 错误并自动断电

然后自动重启，重启时控制台输出的自检信息:

.. literalinclude:: ubuntu_hibernate/hibernate_mce_power_on
   :caption: ``hibernage`` 恢复时出现 :ref:`mce` 错误并自动断电，然后自动启动时控制台显示的自检信息

虽然在 ``dmesg -T`` 系统日志中看不到出错信息，也没有在 :ref:`edac` 状态中看出端倪，不过从 :ref:`hpe_dl360_gen9` 的 :ref:`hp_ilo` WEB控制平台检查 ``Integrated Management Log`` 可以看到如下MCE错误记录:

.. csv-table:: 服务器 ``Integrated Management Log`` 中MCE错误记录
      :file: ubuntu_hibernate/mce.csv
      :widths: 10, 10, 10, 10, 10, 50
      :header-rows: 1

昨天和前天的 hibernate 也同样有错误

.. csv-table:: 服务器 ``Integrated Management Log`` 中 **昨天** MCE错误记录
      :file: ubuntu_hibernate/mce_1.csv
      :widths: 10, 10, 10, 10, 10, 50
      :header-rows: 1

.. csv-table:: 服务器 ``Integrated Management Log`` 中 **前天** MCE错误记录
      :file: ubuntu_hibernate/mce_2.csv
      :widths: 10, 10, 10, 10, 10, 50
      :header-rows: 1

之前在 :ref:`dl360_gen9_pci_bus_error` 也有PCIe错误，当时通过插拔内存似乎恢复了。

我google一下， `HP支持论坛的Uncorrectable Machine Check Exception一个帖子提到的情况 <https://community.hpe.com/t5/proliant-servers-ml-dl-sl/uncorrectable-machine-check-exception/td-p/7008326>`_ 启发了我:

- 看起来PCIe错误导致的MCE，而PCIe错误关联的处理器有 Processor 1 也有 Processor 2(两个处理器同时硬件故障可能性极低)
- 感觉时PCIe上连接的设备触发的问题，在 ``hibernate`` 恢复时响应出现了问题导致主机判断为MCE错误
- 怀疑 :ref:`intel_optane_m10` 最近添加在PCIe转接卡上，这个设备初始化非常诡异，之前有无法识别的问题，可能会在 ``hibernate`` 恢复时无法恢复到休眠前状态，导致触发 :ref:`mce` 错误

虽然可以通过硬件替换，逐个排除PCIe上设备是否和 ``hibernate`` 时 :ref:`mce` 错误有关，但是我现在暂时没有时间继续折腾。目前看平时运行时是稳定的，只在 ``hibernate`` 恢复时触发异常，待后续观察或者有时间再排查。

参考
======

- `archlinux wiki:Power management/Suspend and hibernate <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate>`_
- `How To Enable Hibernation On Ubuntu (When Using A Swap File) <https://www.linuxuprising.com/2021/08/how-to-enable-hibernation-on-ubuntu.html>`_
