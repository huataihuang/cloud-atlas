.. _fstrim:

=====================
fstrim服务及周期TRIM
=====================

在 :ref:`linux_ssd` 上，需要激活文件系统 ``TRIM`` 来实现降低写入放大、延长SSD设备使用寿命。所谓TRIM，就是一种声明设备上没有使用的块，对于没有需要数据的块可以返回给存储池重新使用。我们有两种方式激活文件系统的TRIM功能:

- 持久化TRIM: 挂载文件系统的时候，使用 ``discard`` 参数，例如

对于 EXT4文件系统 增加挂载参数::

   mount -t ext4 -o discard /dev/sda2 /mnt

对于XFS文件系统，在 ``/etc/fstab`` 中也可以配置该参数::

   UUID=3453g54-6628-2346-8123435f  /home  xfs  defaults,discard   0 0

上述 ``discard`` 参数都会激活文件系统的持续TRIM，也就是每次新数据写入磁盘都会激活TRIM。这个方式也引发了是否存在潜在性能影响的争论。

- 周期性TRIM: 通过定时任务定时触发TRIM

传统上定时任务采用 ``cron`` 实现，不过在现代化的 :ref:`systemd` 系统，可以采用和系统更为紧密结合的 :ref:`systemd_timer` 来实现，下文就是采用一条简单的 ``fstrim.timer`` 服务激活实现周期性TRIM

TRIM服务 ``fstrim``
====================

- 在终端执行以下命令来确定 ``fstrim`` 命令是否可以正常根据 ``fstab`` 配置调用::

   sudo /usr/sbin/fstrim --fstab --verbose --quiet

此时会看到类似以下输出::

   /var/lib/docker: 183.4 GiB (196879622144 bytes) trimmed on /dev/disk/by-uuid/d80f2f08-3b50-4b19-a0eb-058fb47693b0
   /boot/efi: 505.8 MiB (530321408 bytes) trimmed on /dev/disk/by-uuid/7E7B-5E3A
   /: 6.6 GiB (7021338624 bytes) trimmed on /dev/disk/by-uuid/caa4193b-9222-49fe-a4b3-89f1cb417e6a

这表明当前挂载的文件系统可以正确实现TRIM

- ``fstrim`` 的 ``--help`` 提供了简洁说明::

   sudo /usr/sbin/fstrim --help

输出显示::

   Usage:
    fstrim [options] <mount point>
   
   Discard unused blocks on a mounted filesystem.
   
   Options:
    -a, --all           trim all supported mounted filesystems
    -A, --fstab         trim all supported mounted filesystems from /etc/fstab
    -o, --offset <num>  the offset in bytes to start discarding from
    -l, --length <num>  the number of bytes to discard
    -m, --minimum <num> the minimum extent length to discard
    -v, --verbose       print number of discarded bytes
        --quiet         suppress error messages
    -n, --dry-run       does everything, but trim
   
    -h, --help          display this help
    -V, --version       display version

- 如果只想查看一下设置是否正确，模拟TRIM(不实际执行TRIM)可以执行::

   sudo /usr/sbin/fstrim --fstab --verbose --dry-run

- 可以执行TRIM显示每个文件系统的TRIM操作::

   sudo /usr/sbin/fstrim --fstab --verbose

激活定时TRIM
===============

对于 Fedora 30 / RHEL 8 / CentOS 8 提供了 :ref:`systemd_timer` 服务，周期性执行 ``fstrim.timer`` ::

   sudo systemctl status fstrim.timer

在 Ubuntu 20.04.3 LTS 上， ``fstrim.timer`` 默认激活，所以显示如下::

   ● fstrim.timer - Discard unused blocks once a week
        Loaded: loaded (/lib/systemd/system/fstrim.timer; enabled; vendor preset: enabled)
        Active: active (waiting) since Wed 2021-10-20 17:52:32 CST; 21h ago
       Trigger: Mon 2021-10-25 00:00:00 CST; 3 days left
      Triggers: ● fstrim.service
          Docs: man:fstrim
   
   Oct 20 17:52:32 zcloud systemd[1]: Started Discard unused blocks once a week.

如果没有激活，可以通过以下命令执行激活::

   sudo systemctl enable fstrim.timer

可以通过以下命令检查 :ref:`systemd_timer` 配置::

   sudo systemctl list-timers --all

显示如下::

   NEXT                        LEFT          LAST                        PASSED      UNIT                         ACTIVATES
   ...
   Mon 2021-10-25 00:00:00 CST 3 days left   Mon 2021-10-18 00:00:24 CST 3 days ago  fstrim.timer                 fstrim.service

现在你可以放心使用 :ref:`linux_ssd` 设备了。

禁用fstrim的情况
==================

以下情况下需要禁用周期性TRIM:

- 底层设备是 ``thin-provisioned`` (精简分配)

**并且**

- 文件系统内部不使用 ``UNMAP`` (trim是ata指令，对应scsi指令是unmap)

.. note::

   ``thin-provisioned`` (精简分配) 策略是虚拟化根据虚拟环境中的实际使用情况实现存储资源的“过度分配（over-commit）”功能。“存储过度分配”是指分配给虚拟机的存储总量比存储池中所具有的物理存储总量要大。通常情况下，虚拟机不会使用分配给它们的全部存储资源。从用户的角度来看，使用精简分配功能的虚拟机完全具有了所有定义的存储空间；而实际上，只有一部分存储空间被实际分配给虚拟机。 -- `Red Hat Virtualization 2.11. 精简分配（THIN
   PROVISIONING）和存储过度分配（OVER-COMMITMENT） <https://access.redhat.com/documentation/zh-cn/red_hat_virtualization/4.1/html/technical_reference/over-commitment>`_

fstrim (或者通常是 TRIM/DISCARD) 在 ``over-provisioned`` 过度分配的系统上操作和 ``thin-provisioned`` 精简分配系统处理方式是不同的。如果系统在每个LUN(不论是不是精简分配)都分配了足够的空间，则不需要TRIM指令。然而，在SAP HANA是不建议使用 ``over-provisioned`` 过度分配系统，而且也强烈建议 ``不`` 使用精简分配设备。

- 检查文件系统是否支持 ``UNMAP`` 的方法是使用 ``lsblk -D`` 命令，如果 ``DISC-MAX`` 值是 ``0`` 就标识设备不支持 ``discard`` 功能::

   lsblk -D

输出类似::

   NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
   sda           0      512B       2G         0
   ├─sda1        0      512B       2G         0
   ├─sda2        0      512B       2G         0
   └─sda3        0      512B       2G         0
   sdb           0        0B       0B         0
   └─sdb1        0        0B       0B         0
   sdc           0        0B       0B         0
   ├─sdc1        0        0B       0B         0
   └─sdc2        0        0B       0B         0
   sdd           0        0B       0B         0
   ├─sdd1        0        0B       0B         0
   └─sdd2        0        0B       0B         0

可以看到 ``sdb`` , ``sdc`` , ``sdd`` 存储设备不支持 ``UNMAP`` / ``TRIM`` ，实际上是传统的机械硬盘。

- 使用 ``fstrim`` 命令也可以验证::

   sudo mount /dev/sdb1 /mnt
   sudo fstrim -v /mnt

可以看到信息::

   fstrim: /mnt: the discard operation is not supported

虚拟机
==========

在虚拟机内部， ``fstrim.service`` 是没有效果的，除非虚拟块设备宣告它支持 ``discard`` 。在 ``virt-manager`` 虚拟化管理器中，需要对块设备设置::

   Advanced options>Performance options>Discard mode: unmap

默认情况下 ``virt-manager`` 的 ``qemu-kvm`` 虚拟机会忽略 ``discard`` 执行，所以虽然 ``ftrim.service`` 显示执行成功，但是内核日志会显示这个执行失败::

   [ 122.895923 ] localhost.localdomain kernel: blk_update_request: operation not supported error, dev vda, sector 206856170 op 0x3:(DISCARD) flags 0x0 phys_seg 2 prio class 0

如果对支持的存储设置VM使用 ``unmap`` ，此时 ``fstrim`` 指令会 pass through 透传给底层块存储；如果底层块存储是 ``raw`` 或者 ``qcow2`` 则该文件会编程一个稀疏(sparse)文件。

容器
=====

从 ``util-linux 2.35`` 开始，也就是 Fedora 32开始， ``fstrim.service`` 包含了以下配置::

   ConditionVirtualization=!container

:ref:`docker_systemd` 通过Docker环境变量 ``container=docker`` 可以知道自己运行在容器内部，也就会停止运行 ``fstrim.service`` 。

参考
======

- `Changes/EnableFSTrimTimer <https://fedoraproject.org/wiki/Changes/EnableFSTrimTimer>`_
- `Extend the life of your SSD drive with fstrim - A new systemd service to make your life easier <https://opensource.com/article/20/2/trim-solid-state-storage-linux>`_
- `Disabling fstrim - under which conditions? <https://www.suse.com/support/kb/doc/?id=000019447>`_
