.. _remount_without_reboot:

===========================
无需重启重新挂载文件系统
===========================

通常修改Linux文件系统挂载配置 ``/etc/fstab`` 会需要重启系统，但是实际上有一个简单的方法可以重新挂载所有 ``/etc/fstab`` 配置中的分区而无需重启系统::

   mount -a

这个简单的命令会重新挂载分区，但是对于 ``noauto`` 选项无效。

举例，在 :ref:`linux_ssd` ，需要激活SSD上文件系统的 ``discard`` 选项

- 默认的 ``/etc/fstab`` 配置::

   /dev/disk/by-uuid/c22eff09-c2d2-45b4-82db-1ea988ca88ef / ext4 defaults 0 1

- 检查 mount 状态::

   mount

输出显示::

   /dev/sda2 on / type ext4 (rw,relatime)

- 检查TRIM::

   lsblk --discard

显示::

   NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
   sda           0      512B       2G         0
   ├─sda1        0      512B       2G         0
   └─sda2        0      512B       2G         0

- 修改 ``/etc/fstab`` 添加 ``discard`` 选项::

   /dev/disk/by-uuid/c22eff09-c2d2-45b4-82db-1ea988ca88ef / ext4 defaults,discard 0 1

- 然后执行 ``mount -a`` 命令会看到并没有任何输出信息，那么到底有没有生效呢？

- 再次执行 ``mount`` 查看输出::

   /dev/sda2 on / type ext4 (rw,relatime)

果然没有生效

- 那么我们尝试::

   mount -o remount -a

就会发现，原来对于已经挂载的根文件系统，默认是不能重新挂载的 ``mount -a`` 实际上是先卸载再挂载，所以提示::

   mount: ???: operation failed: Device or resource busy.
   mount: ???: operation failed: Device or resource busy.
   ...

在线添加mount参数
====================

- 有没有办法即时生效呢？毕竟我们只是增加一个挂载参数而不是删除参数。方法是明确添加参数::

   mount -o remount,discard /

此时没有任何信息输出，但是通过 ``mount`` 命令检查，可以看到 ``discard`` 参数添加::

   /dev/sda2 on / type ext4 (rw,relatime,discard)

.. note::

   上述在文件系统中添加 ``discard`` 将激活 持续性TRIM ，对于一些SATA设备可能会触发冻结问题(不支持queued TRIM)，所以发行版通常不建议使用持续性TRIM。

在线删除mount参数
=====================

- 不需要的挂载参数可以反向去除，例如，上面的 ``discard`` 参数可以用 ``nodiscard`` 来消除::

   mount -o remount,nodiscard /

然后再用 ``mount`` 命令检查可以看到 ``discard`` 参数消除::

   /dev/sda2 on / type ext4 (rw,relatime)

参考
=====

- `HowTo: Remount /etc/fstab Without Reboot in Linux <https://www.shellhacks.com/remount-etc-fstab-without-reboot-linux/>`_
- `How do you validate fstab without rebooting? <https://serverfault.com/questions/174181/how-do-you-validate-fstab-without-rebooting>`_
- `attempting to remove discard mount option <https://superuser.com/questions/1285572/attempting-to-remove-discard-mount-option>`_
