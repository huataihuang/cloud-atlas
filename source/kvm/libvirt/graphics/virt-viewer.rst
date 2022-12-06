.. _virt-viewer:

==================================
virt-viewer虚拟机图形管理接口工具
==================================

除了 ``virt-manager`` ，RHEL还提供了一个mini化的命令行工具 ``virt-viewer`` 来显示虚拟机的图形控制台。这个图形控制台可以使用 ``vnc`` 或 ``spice`` 协议，虚拟机访问可以引用为虚拟机名字，ID或UUID。

如果虚拟机还没有启动，viewer可以设置成在尝试连接到控制台前处于等待。

``virt-viewer`` 虽然没有提供 ``virt-manager`` 完整的功能，但是需要的资源少，并且大多数情况下， ``virt-viewer`` 不需要 ``libvirt`` 的读写权限，所以可以提供给不需要配置功能的普通用户。

virt-viewer使用
===================

使用方法::

   virt-viewer [OPTIONS] {guest-name|id|uuid}

案例:

- 使用默认hypervisor连接指定虚拟机::

   virt-viewer guest-name

- 使用 ``KVM-QEMU`` hypervisor连接guest虚拟机::

   virt-viewer --connect qemu:///system guest-name

- 使用TLS连接远程控制台::

   virt-viewer --connect qemu://example.org/ guest-name

- 使用SSH连接远程服务器的一个控制台，查询guest配置，然后发起一个直接的非tunneled的连接到控制台::

   virt-viewer --direct --connect qemu+ssh://root@example.org/ guest-name

- 创建一个定制的键盘快捷键(也称为 hotkey)::

   virt-viewer --hotkeys=action1=key-combination1[,action2=key-combination2] guest-name

这里可以使用的hotkey操作如下::

   toggle-fullscreen
   release-cursor
   smartcard-insert
   smartcard-remove

举例::

   virt-viewer --hotkeys=toggle-fullscreen=shift+f11 qemu:///system testguest

kiosk模式
==========

在 ``kiosk`` 模式， ``virt-viewer`` 只允许用户和连接的桌面进行交互，但是不提供任何与guest设置相关加护或者host系统的交互设置，除非guest已经关闭。这种方式适合管理员限制用户访问特定的guest::

   virt-viewer --connect qemu:///system guest-name --kiosk --kiosk-quit on-disconnect

参考
=======

- `RHEL 7 Virtualization Deployment and Administration Guide: Chapter 22. Graphical User Interface Tools for Guest Virtual Machine Management <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/chap-graphic_user_interface_tools_for_guest_virtual_machine_management>`_
