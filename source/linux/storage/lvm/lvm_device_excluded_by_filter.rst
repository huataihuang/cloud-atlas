.. _lvm_device_excluded_by_filter:

======================================================================
LVM执行 ``pvcreate`` 时报错 ``Device /dev/XXX excluded by a filter.``
======================================================================

在部署 :ref:`linux_lvm` 时，有时候我们会在执行 ``pvcreate /dev/XXX`` 时候遇到警示::

   Device /dev/XXX excluded by a filter.

这个报错(我遇到过)通常有两种情况:

- 使用的磁盘是曾经创建过文件系统分区表的磁盘， ``lvm`` 卷管理程序会忽略已经创建过分区表的磁盘分区
- 存储设备驱动特殊，识别为特殊的设备名， ``lvm`` 默认只支持在常见设备，如 ``/dev/sdX`` , ``/dev/vdX`` ，对于特殊设备需要修订 ``lvm.conf`` 增加支持类型

实践案例
===========

在生产环境 :ref:`extend_ext4_on_lvm` 遇到一个困境:

- 对一块已经使用过的磁盘， :ref:`deploy_lvm` 执行:

.. literalinclude:: lvm_device_excluded_by_filter/pvcreate
   :caption: 执行 pvcreate 创建物理卷

此时会报错:

.. literalinclude:: lvm_device_excluded_by_filter/pvcreate_error
   :caption: 执行 pvcreate 创建物理卷报错

- 这个报错我以前也遇到过，也就是我上文说的第一种情况。一般可以参考 `Device /dev/sdX excluded by a filter. <https://access.redhat.com/solutions/3440661>`_ 通过 ``wipefs`` 抹去旧磁盘分区表来修正:

.. literalinclude:: lvm_device_excluded_by_filter/wipefs
   :caption: 执行 wipefs 抹去旧磁盘分区表

提示信息:

.. literalinclude:: lvm_device_excluded_by_filter/wipefs_output
   :caption: 执行 wipefs 抹去旧磁盘分区表时输出信息

我以为已经解决了问题，所以重新再使用 :ref:`parted` 进行分区，然后再次执行 ``pvcreate /dev/dfb1`` 

WHAT?

报错依旧:

.. literalinclude:: lvm_device_excluded_by_filter/pvcreate_error
   :caption: 执行 pvcreate 创建物理卷报错

反复几次，我怀疑是 ``wipefs`` 仅抹去了磁盘开头的分区表，但是没有破坏分区表后面的文件系统?

- 所以我又尝试通过 ``dd`` 命令多抹去一些数据(磁盘开头的2MB):

.. literalinclude:: lvm_device_excluded_by_filter/dd
   :caption: 通过 ``dd`` 抹去磁盘开头2MB数据，试图彻底抹去分区表和文件系统

- 再来一遍，报错依旧

排查
------

- 执行 ``pvcreate`` 的debug模式:

.. literalinclude:: lvm_device_excluded_by_filter/pvcreate_vvv
   :caption: 使用 ``-vvv`` 参数详细调试 ``pvcreate``

此时会输出详细调试信息，注意观察出现报错前后的信息:

.. literalinclude:: lvm_device_excluded_by_filter/pvcreate_vvv_output
   :caption: 使用 ``-vvv`` 参数详细调试 ``pvcreate`` 输出信息
   :emphasize-lines: 23,24

奇怪， ``device type 253`` 是什么鬼? 为何不能识别而跳过?

- 依次执行一些lvm检查命令进行排查:

.. literalinclude:: lvm_device_excluded_by_filter/lvm_debug
   :caption: 排查lvm

- 关键命令，通过 ``/proc/devices`` 设备识别:

.. literalinclude:: lvm_device_excluded_by_filter/proc_devices
   :caption: 通过 ``/proc/devices`` 可以识别出设备名以及对应设备号

从设备输出中果然可以找到编号为 ``253`` 的设备:

.. literalinclude:: lvm_device_excluded_by_filter/proc_devices_output
   :caption: 通过 ``/proc/devices`` 可以找到 ``id`` 是 ``253`` 的设备
   :emphasize-lines: 9

明白了，原来我们服务器使用了 ``aliflash`` 存储设备(国产化设备)

LVM默认只配置了常规的磁盘设备名，我们服务器上使用了特殊的 ``aliflash`` 设备，这个设备被识别为 ``/dev/dfX`` ，需要增加到 ``/etc/lvm/lvm.conf`` 中设备类型

- 检查磁盘设备:

.. literalinclude:: lvm_device_excluded_by_filter/ls_dfX_devices
   :caption: 检查磁盘设备

可以看到 ``dfX`` 设备的id确实是 ``253`` (第5列):

.. literalinclude:: lvm_device_excluded_by_filter/ls_dfX_devices_output
   :caption: 检查磁盘设备

修正
------

修改 ``/etc/lvm/lvm.conf`` 添加::

   types = [ "aliflash", 16 ]

这样就能够匹配使用 ``/dev/dfa`` 和 ``/dev/dfb`` 等设备(注意，不是配置 ``df`` ，而是配置 ``/proc/devices`` 中设备名 ``aliflash`` 也就是对应报错中 ``253`` id的设备名)

然后执行::

   lvmdiskscan

就会看到新增加了识别出可用的设备::

   /dev/sda1 [       3.00 MiB]
   /dev/dfa1 [       5.82 TiB]
   /dev/sda2 [       1.00 GiB]
   /dev/sda3 [      50.00 GiB]
   /dev/sda4 [       2.00 GiB]
   /dev/sda5 [    <263.72 GiB]
   /dev/dfb1 [       5.82 TiB]
   0 disks
   7 partitions
   0 LVM physical volume whole disks
   0 LVM physical volumes

现在就可以为 ``/dev/dfb1`` 和 ``/dev/dfa1`` 添加 LVM 标记了

再次执行::

   pvcreate /dev/dfb1

就会提示成功::

   Physical volume "/dev/dfb1" successfully created.

- 后面就可以正常使用::

   vgcreate vg-data /dev/dfb1

提示::

   Volume group "vg-data" successfully created

其他检查::

   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        1
     Metadata Sequence No  1
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                0
     Open LV               0
     Max PV                0
     Cur PV                1
     Act PV                1
     VG Size               5.82 TiB
     PE Size               4.00 MiB
     Total PE              1525878
     Alloc PE / Size       0 / 0
     Free  PE / Size       1525878 / 5.82 TiB
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n

- 创建LVM::

   lvcreate -n lv-thanos -L 5.82T vg-data

提示::

   Rounding up size to full physical extent 5.82 TiB
   Logical volume "lv-thanos" created.

- 检查lvm::

   #lvdisplay
     --- Logical volume ---
     LV Path                /dev/vg-data/lv-thanos
     LV Name                lv-thanos
     VG Name                vg-data
     LV UUID                ELdzbI-Jdg8-5N1L-0S3C-tXxO-lvm9-abHl3n
     LV Write Access        read/write
     LV Creation host, time alipaydockerphy010052095245.et15, 2023-07-29 15:33:17 +0800
     LV Status              available
     # open                 0
     LV Size                5.82 TiB
     Current LE             1525679
     Segments               1
     Allocation             inherit
     Read ahead sectors     auto
     - currently set to     256
     Block device           251:0
   
   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        1
     Metadata Sequence No  2
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               0
     Max PV                0
     Cur PV                1
     Act PV                1
     VG Size               5.82 TiB
     PE Size               4.00 MiB
     Total PE              1525878
     Alloc PE / Size       1525679 / 5.82 TiB
     Free  PE / Size       199 / 796.00 MiB
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n

看来还是不要指定 lv 大小，最好能够百分百

改为::

    lvcreate -n lv-thanos -l 100%FREE vg-data

则提示是完整的::

   Logical volume "lv-thanos" created.

此时看vg-data已经全部分配完::

   #vgdisplay
     --- Volume group ---
     VG Name               vg-data
     System ID
     Format                lvm2
     Metadata Areas        1
     Metadata Sequence No  4
     VG Access             read/write
     VG Status             resizable
     MAX LV                0
     Cur LV                1
     Open LV               0
     Max PV                0
     Cur PV                1
     Act PV                1
     VG Size               5.82 TiB
     PE Size               4.00 MiB
     Total PE              1525878
     Alloc PE / Size       1525878 / 5.82 TiB
     Free  PE / Size       0 / 0
     VG UUID               VnvQM9-hcX6-gVqL-Nlsl-q7GP-CIC6-Dwbx6n


参考
======

- `ScaleIO Software: Failed to create physical volumes on Linux ScaleIO devices <https://www.dell.com/support/kbdoc/zh-cn/000055014/failed-to-create-pv-on-linux-scaleio-devices>`_
- `[linux-lvm] pvcreate ignores volumes with error code:253 <https://linux-lvm.redhat.narkive.com/YswkYETj/pvcreate-ignores-volumes-with-error-code-253>`_
- `Device /dev/sdX excluded by a filter. <https://access.redhat.com/solutions/3440661>`_
- `lvcreate with max size available <https://www.linuxquestions.org/questions/linux-hardware-18/lvcreate-with-max-size-available-749253/>`_ 和 `5.4. Logical Volume Administration <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/logical_volume_manager_administration/lv>`_
