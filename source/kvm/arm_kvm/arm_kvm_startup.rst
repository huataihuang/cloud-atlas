.. _arm_kvm_startup:

====================
ARM环境KVM快速起步
====================

ARM对虚拟化支持最初是从ARMv7-A处理器开始对额，包括Cortex-A15(ARM A系列第一款支持硬件虚拟化), Cortex-A7 和 Cortex-A17。而ARMv8-A 处理器也支持虚拟化。 :ref:`arm_kvm_support`

我的ARM测试环境是 :ref:`raspberry_pi` 的 :ref:`pi_4` ，根据硬件规格，采用的是 4核心Cortex-A72(ARM v8) 64位处理。

安装
=======

Ubuntu for ARM
-----------------

- 安装libvirt::

   sudo apt install qemu-system-arm libvirt-daemon-system virtinst bridge-utils

.. note::

   虽然不安装libvirt也能够直接通过 ``qemu`` 来直接运行虚拟机，但是 :ref:`libvirt` 提供了通用且丰富的管理功能，方便我们维护qemu虚拟化。

   对于 x86 平台，安装 ``qemu-kvm`` 代替 ``qemu-system-arm``

.. note::

   ``virtinst`` 软件包提供了 ``virt-install`` 命令行维护工具

   ``bridge-utils`` 软件包提供了 ``brctl`` 维护bridge的工具

- 安装完成后 ``libvirtd`` 已经自动启动，通过以下命令检查状态::

   sudo systemctl status libvirtd

- 执行 ``sudo virsh list`` 可以检查是否可以正常访问 libvirt 服务

- 将需要管理虚拟化的用户账号，例如当前账号 ``huatai`` 添加到 ``libvirt`` 组，这样就不需要 ``sudo`` 就可以管理::

   sudo adduser $USER libvirt

Fedora for ARM
-----------------

.. note::

   我暂时没有Fedora环境验证，本段落摘自 `How to Enable KVM Virtualization on Raspberry Pi 4 <https://linuxhint.com/kvm_virtualization_raspberry_pi4/>`_

- 首先更新DNF软件包仓库缓存::

   sudo dnf makecache

- 安装KVM以及所有相关工具，在Fedora上只需要以group方式安装 ``Virtualizaiont`` ::

   sudo dnf group install "Virtualization"

- 将本登陆用户添加到 ``libvirt`` 组::

   sudo usermod -aG libvirt $(whoami)

- 重启系统::

   sudo reboot

NAT网络
==========

在 :ref:`pi_4` 上运行 :ref:`kali_linux` 版本libvirt，有可能默认没有激活任何虚拟网络(即 ``default`` 网络，也就是NAT网络)。可以参考 :ref:`libvirt_nat_network` 检查和激活：

- 检查libvirt网络::

   virsh net-list

输出显示是空白::

    Name   State   Autostart   Persistent
   ----------------------------------------

- 检查所有libvirt网络(包括没有激活的网络)::

   virsh net-list --all

显示有一个 ``default`` 网络没有激活::

    Name      State      Autostart   Persistent
   ----------------------------------------------
    default   inactive   no          yes

- 激活 ``default`` 网络并设为默认启动::

   virsh net-start default
   virsh net-autostart default

- 然后检查验证::

   virsh net-list

显示状态::

    Name      State    Autostart   Persistent
   --------------------------------------------
    default   active   yes         yes


安装虚拟机
================

Ubuntu提供了官方Ubuntu Server ARM版本，可以作为KVM虚拟机运行在 :ref:`pi_4` 上。从 `Ubuntu downloads <https://ubuntu.com/download>`_ 下载 `Ubuntu Server for ARM iso镜像 <https://ubuntu.com/download/server/arm>`_ ，我这里下载的是 ``Ubuntu 20.04.2 LTS`` 版本。

下载的iso镜像移动到 ``/var/lib/libvirt/images/`` 目录下

如果你运行的是Linux 桌面版本 for ARM，可以运行一个 Virtual Machine Manager (VMM) 图形化程序来安装运行虚拟机。不过，我比较喜欢命令行操作，所以和 :ref:`create_vm` 采用相同方法创建虚拟机::

   virt-install \
     --network bridge:virbr0 \
     --name ubuntu20.04 \
     --ram=2048 \
     --vcpus=2 \
     --os-type=ubuntu20.04 \
     --disk path=/var/lib/libvirt/images/ubuntu20.04.qcow2,format=qcow2,bus=virtio,cache=none,size=16 \
     --graphics none \
     --cdrom=/var/lib/libvirt/images/ubuntu-20.04.2-live-server-arm64.iso

其他可以安装的ARM虚拟机发行版:

- `Fedora ARM发行版 <https://fedoraproject.org/wiki/Architectures/ARM>`_ 

请下载ARM aarch64架构服务器版本，例如 Fedora Server netinstall iso 或者 Fedora Minimal （raw镜像)。此外，Fedora还发布了 Fedora CoreOS 版本(2020年5月26日起替代了原先基于Gentoo Linux开发的Container Linux)，如果希望专注运行容器或Kubernetes容器编排集群，则建议采用 Fedora CoreOS for ARM

- `CentOS.org <https://www.centos.org/>`_ 提供的 CentOS Linux 或 CentOS Stream (滚动发布) 发行版，都提供了 aarch64 的ARM版本

.. note::

   Ubuntu Server版本默认启用了snapd提供snap安装支持，如果不需要(例如我主要使用docker容器化)，我建议 :ref:`disable_snap`

参考
======

- `KVM Process support <https://www.linux-kvm.org/page/Processor_support>`_
- `How to Enable KVM Virtualization on Raspberry Pi 4 <https://linuxhint.com/kvm_virtualization_raspberry_pi4/>`_ - 使用 Fedora 33 on :ref:`pi_4` 来运行KVM虚拟化
- `Ubuntu wiki arm64/QEMU <https://wiki.ubuntu.com/ARM64/QEMU>`_
