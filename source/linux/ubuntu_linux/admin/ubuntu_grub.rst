.. _ubuntu_grub:

============================
Ubuntu修订Grub内核启动参数
============================

在 :ref:`intel_vt-d_startup` 中设置内核参数 ``intel_iommu=on`` ，添加到 :ref:`ubuntu_linux` 启动参数，该方法也是Ubuntu Linux修改内核启动参数的标准方法。

- 修改 ``/etc/default/grub`` ::

   GRUB_CMDLINE_LINUX_DEFAULT=""
   GRUB_CMDLINE_LINUX=""

修改成::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on"
   GRUB_CMDLINE_LINUX=""

- 然后执行::

   sudo update-grub

- 重启操作系统，然后执行以下命令检查::

   cat /proc/cmdline

可以看到::

   BOOT_IMAGE=/boot/vmlinuz-5.4.0-88-generic root=UUID=caa4193b-9222-49fe-a4b3-89f1cb417e6a ro intel_iommu=on

参考
======

- `Ubuntu wiki: KernelBootParameters <https://wiki.ubuntu.com/Kernel/KernelBootParameters>`_
- `How do I add a kernel boot parameter? <https://askubuntu.com/questions/19486/how-do-i-add-a-kernel-boot-parameter>`_
