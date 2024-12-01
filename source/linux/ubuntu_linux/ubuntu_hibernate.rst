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

# blkid /dev/sda1
/dev/sda1: UUID="4525e419-1e24-48e8-9b7c-e03d281d7b41" TYPE="swap" PARTLABEL="swap" PARTUUID="ba7c6674-5d6e-4aa5-a2ed-cb0e265b73b7"

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

参考
======

- `archlinux wiki:Power management/Suspend and hibernate <https://wiki.archlinux.org/index.php/Power_management/Suspend_and_hibernate>`_
- `How To Enable Hibernation On Ubuntu (When Using A Swap File) <https://www.linuxuprising.com/2021/08/how-to-enable-hibernation-on-ubuntu.html>`_
