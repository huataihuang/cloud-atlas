.. _devstack:

=================
DevStack
=================

DevStack是一个可扩展脚本用于基于最新git master版本快速启动一个完整的OpenStack环境。DevStack主要用于作为开发环境以及作为OpenStack项目功能测试。

DevStack源代码位于 https://git.openstack.org/cgit/openstack-dev/devstack

.. warning::

   由于DevStack会显著修改系统，所以只应该运行在独立的专用于DevStack的主机或虚拟机。

快速起步
============

安装Linux
------------

最小化安装Linux，DevStack会尝试支持最新的两个LTS版本Ubuntu，以及最新的Fedora，CentOS/RHEL 7，以及Debian和OpenSUSE。当前测试最充分和完善运行的是Ubuntu 16.04版本。

在我的模拟环境中通过 :ref:`clone_vm` 创建 ``devstack`` 测试虚拟机::

   virt-clone --connect qemu:///system --original ubuntu18.04 --name devstack --file /var/lib/libvirt/images/devstack.qcow2
   sudo virt-sysprep -d devstack --hostname devstack --root-password password:CHANGE_ME
   virsh start devstack

.. note::

   运行DevStack的虚拟机内存建议使用4G，过小的内存会（例如我测试过1c1g配置）会导致安装过程中，nuturn服务会因为OOM被杀掉，导致反复失败，非常麻烦。这里实际测试虚拟机采用 2c4g 配置::

      virsh setvcpus devstack 2
      virsh setmem devstack 4G

安装DevStack
=================

.. note::

   在我的模拟测试环境中使用了 :ref:`kvm_nested_virtual` ，所以DevStack内部可以运行KVM hypervisor进行管理。

在开始运行DevStack的 ``stack.sh`` 脚本之前，请在KVM虚拟机内部确认已经激活了KVM，即虚拟机内部具有 ``/dev/kvm`` 设备。这又这个设备存在，DevStack才会使用 ``/etc/nova.conf`` 配置中的 ``virt_type = kvm`` ，否则就会使用 QEMU 模拟 ``virt_type = qemu`` ，这会影响性能。

此外，为了明确设置虚拟化类型，设置成KVM，在DevStack的 ``local.conf`` 配置中激活::

   LIBVIRT_TYPE=kvm

一旦DevStack中运行了Nova实例，请通过 ``ps`` 命令检查进程，取保具有参数 ``accel=kvm`` ，类似::

   ps -ef | grep -i qemu
   root     29773     1  0 11:24 ?        00:00:00 /usr/bin/qemu-system-x86_64 -machine accel=kvm [. . .]

- 添加Stack用户::

   sudo useradd -s /bin/bash -d /opt/stack -m stack
   echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

.. note::

   DevStack使用non-root用户的sudo方式执行

- 下载OpenStack::

   git clone https://git.openstack.org/openstack-dev/devstack
   cd devstack

- 创建 ``local.conf``::

   [[local|localrc]]
   ADMIN_PASSWORD=secret
   DATABASE_PASSWORD=$ADMIN_PASSWORD
   RABBIT_PASSWORD=$ADMIN_PASSWORD
   SERVICE_PASSWORD=$ADMIN_PASSWORD

.. note::

   在 ``samples`` 目录下有一个样例 `lcoal.conf <https://docs.openstack.org/devstack/latest/_downloads/53dedb4323840e7ad95d0617fa0ec2e4/local.conf>`_

- 启动安装::

   ./stack.sh

.. note::

   devstack 将安装 ``keystone, glance, nova, placement, cinder, neutron, and horizon`` ，并且使用 Floating IP ，所以guests系统可以访问外部。

访问DevStack
=================

在shell环境中，使用 ``source openrc`` ，然后就可以使用 ``openstack`` 命令来管理 devstack。


