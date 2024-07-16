.. _lfs_partition:

====================
LFS分区(物理主机)
====================

:ref:`lfs_vm` 虽然适合测试，但是作为虚拟机运行LFS，总是觉得有点"隔靴搔痒"，不能让人玩得痛快。

我的 :ref:`mbp15_late_2013` 同时安装了 :ref:`macos` 和 :ref:`gentoo_linux` ( :ref:`install_gentoo_on_mbp` )，考虑到LFS是非常精简的系统，我后续也有想法深入折腾，所以我在macOS中通过磁盘工具缩减了macOS的APFS分区，空出一部分(大约30G)。这样，我在切换到Gentoo Linux系统时，就可以直接对这个分区进行操作，编译定制自己的LFS系统安装到这个分区。(UEFI分区已经存在，是macOS和Gentoo Linux共用的，也用于LFS；无需再创建)

- 执行 ``parted /dev/nvme0n1 print`` 检查可以看到将要用于LFS的分区3:

.. literalinclude:: lfs_partition/parted_print_output
   :caption: ``parted`` 检查用于LFS的分区
   :emphasize-lines: 10

后续执行步骤中，我将在 :ref:`lfs_vm` (虚拟机) 和 :ref:`lfs_partition` (物理机) 的磁盘区分部分，分别做差异步骤记录。总体安装的软件步骤是一致的，所以软件步骤相同的合并成一份撰写，差异部分分别说明。

虚拟机运行物理主机分区
=========================

使用物理分区来构建LFS，如果每次都需要重启主机切换OS显得非常麻烦。一个思路是将这里的LFS物理分区直接传递给虚拟机，这样我就能在Gentoo Linux上直接测试和调整LFS，即方便又高效。

不过需要注意，虽然可以直接将物理磁盘的某个分区传递给虚拟机作为一块虚拟磁盘，但是这会导致虚拟机在这个分区内部再次写入分区表(GPT分区表)，就和物理主机使用整块磁盘冲突了(此时分区中不应该有类似整个磁盘的分区表)。解决的方法参考 `rvirtesp <https://gitlab.com/ranolfi/rvirtesp>`_ ，也就是:

- 配置虚拟机使用整个磁盘
- 虚拟机启动时，通过hook自动卸载物理主机挂载的UEFI分区，让这个UEFI分区能够被虚拟机读写
- 虚拟机的使用的数据分区不能被物理主机挂载，虚拟机也不要挂载物理主机已经使用的分区

具体待我后续实践，相关解释案例见:

- `Add physical partition to QEMU/KVM virtual machine in virt-manager <https://askubuntu.com/questions/927574/add-physical-partition-to-qemu-kvm-virtual-machine-in-virt-manager>`_
- `Run script in the host when starting virtual machine with virt-manager <https://unix.stackexchange.com/questions/374551/run-script-in-the-host-when-starting-virtual-machine-with-virt-manager>`_
