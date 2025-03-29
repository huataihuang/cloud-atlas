.. _ubuntu_vm_console:

=====================
Ubuntu虚拟机控制台
=====================

:ref:`create_vm` 发现Ubuntu 20.04 安装过程可以使用控制台，但是操作系统安装完成后重启虚拟机则没有信息从控制台输出。这说明Ubuntu操作系统默认内核没有采用串口控制台输出配置。

- 检查 ``/var/lib/libvirt/dnsmasq/virbr0.status`` 可以看到当前分配的虚拟机IP地址::

   [
     {
       "ip-address": "192.168.122.138",
       "mac-address": "52:54:00:1a:37:36",
       "hostname": "z-ubuntu20",
       "client-id": "ff:56:50:4d:98:00:02:00:00:ab:11:13:60:1f:56:db:60:fb:ec",
       "expiry-time": 1637134559
     }
   ]

- 使用安装过程中创建的具有sudo权限的帐号登录虚拟机::

   ssh huatai@192.168.122.138

- 检查 ``/etc/default/grub`` 可以看到配置最后有::

   GRUB_CMDLINE_LINUX="" 
   GRUB_TERMINAL=serial
   GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200 --stop=1"

对比了一下正常的Fedora 35虚拟机，Fedora 35虚拟机配置::

   GRUB_TERMINAL="serial console"
   GRUB_SERIAL_COMMAND="serial --speed=115200"
   GRUB_CMDLINE_LINUX="console=ttyS0,115200"

- 模仿Fedora配置修订Ubuntu的 ``/etc/fault/grub`` 配置::

   GRUB_TERMINAL="serial console"
   GRUB_SERIAL_COMMAND="serial --speed=115200"
   GRUB_CMDLINE_LINUX="console=ttyS0,115200"

- 然后更新grub::

   sudo update-grub

- 重启系统以后就可以正确在 ``virsh console`` 控制台看到终端输出

参考
======

- `Libvirt: virsh console - no response <https://askubuntu.com/questions/909617/libvirt-virsh-console-no-response>`_
