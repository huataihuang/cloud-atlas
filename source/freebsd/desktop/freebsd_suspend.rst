.. _freebsd_suspend:

======================
FreeBSD休眠
======================

现状
======

虽然 FreeBSD 官方内核和 ACPI 子系统支持进入睡眠状态(如常见的 S3 睡眠到内存 ``acpiconf -s 3`` )，但原生的、内核级的 ``S4`` **休眠到磁盘** (将内存镜像完整写入 Swap 并安全断电恢复) 在很多现代主板和笔记本上无法 :strike:`开箱即用` 实现。

核心现状与难点:

- 驱动与硬件支持局限

  - FreeBSD 的 ACPI 实现对 ``S3`` ( **Suspend-to-RAM** ) 的支持相对较好，合盖或执行 ``acpiconf -s 3`` 可以让很多机器顺利休眠到内存。
  - 但对于 ``S4`` ( **Suspend-to-Disk** )，由于需要硬件固件(BIOS/UEFI)、ACPI 表以及内核底层(如驱动状态保存、硬件唤醒上下文恢复)的完美配合，绝大多数 PC 硬件在 FreeBSD 下执行 ``S4`` 时会遭遇唤醒失败、内核 Panic 或直接重启。

.. note::

   在Linux上配置Hibernate( **Suspend-to-Disk** )不仅要求Swap分区大小能够容纳物理内存内容，而且还需要在 ``initramfs`` (如Dracut或Initramfs-tools)中注入驱动和 ``resume=UUID`` 参数，以便内核在引导初期把磁盘的内存镜像读回内存。

.. note::

   - Linux 的休眠依赖于内核内置的 ``swsusp`` (Software Suspend)机制，它由内核负责将内存页序列化并写入指定的Swap块设备(FreeBSD的内核电源管理子系统acpi长期以来没有实现通用的软件级S4状态持久化与恢复引擎)
   - 硬件/BIOS: FreeBSD历史上仅支持一种被称为 ``S4BIOS`` 的过渡方案，需要老旧的主板BIOS固件自己来处理所有的内存快照保存和恢复工作。但是现代主机的硬件和UEFI/BIOS已没有这个机制
   - 虽然FreeBSD社区和基金会近年来开始着手调研和推进 S4 Hibernation 的相关功能，但在当前的 FreeBSD 15 中，它尚未形成可用、稳定的终端用户方案。

- 缺乏像 Linux ``pm-utils`` 或 ``systemd-hibernate`` 那样的成熟上层支持

  - FreeBSD 没有内置自动把整个 RAM 打包写入 Swap 并安全写入引导恢复指针的通用用户态休眠守护进程

测试
=====

由于 FreeBSD 的 ``S4`` 休眠到磁盘在实际生产和日常使用中极不稳定，社区通常采用 S3 睡眠(Suspend-to-RAM):

- 使用命令行验证主机是否能够完成 ``S3`` (Suspend-to-RAM，睡眠到内存):

.. literalinclude:: freebsd_suspend/acpiconf_s3
   :caption: 测试 ``S3`` (Suspend-to-RAM)

在我的 :ref:`thinkpad_x220` 上这个实验非常顺滑，能够完美迅速进入低功耗挂起状态，唤醒时也能极快地恢复现场(网卡、屏幕背光和 USB 端口都能正常激活)。

.. note::

   S3 会持续消耗微量的电池电量(一整夜大约会消耗 5%~10% 的电量)

配置
======

要在笔记本合盖时自动触发 S3 睡眠，既不需要改动 ``/etc/rc.conf`` ，也不依赖 Sway 桌面配置本身。在 FreeBSD 中，系统底层的 ACPI 事件统一由守护进程 ``devd`` 来监听和分发。

.. note::

   FreeBSD 的硬件事件守护进程 devd 可以捕获到电源按钮、AC 适配器插拔以及笔记本合盖（lid switch）的信号。

- 配置 devd 监听合盖事件 ``/etc/devd/lid.conf`` (修改或创建该文件):

.. literalinclude:: freebsd_suspend/lid.conf
   :caption: 配置 devd 监听合盖事件 ``/etc/devd/lid.conf``

这样当 ``devd`` 捕获到来自 ``ACPI`` 子系统的 ``LID`` (合盖)事件时，它会自动在系统日志中记录一条信息，并立即执行 ``acpiconf -s 3`` 让系统进入 ``S3`` 睡眠。
