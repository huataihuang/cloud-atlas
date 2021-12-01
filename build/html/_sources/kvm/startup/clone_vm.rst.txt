.. _clone_vm:

==========================
复制KVM虚拟机
==========================

为了能够在模拟环境中快速创建KVM虚拟机，需要将 :ref:`create_vm` 首个ubuntu虚拟机作为模版，快速clone出需要的部署集群所需虚拟机。

.. note::

   详细操作可以参考 `Clone KVM虚拟机实战 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/clone_kvm_vm_in_action.md>`_ 

clone虚拟机
===============

.. note::

   克隆虚拟机之前，被克隆的虚拟机需要处于停机状态或者暂停状态（ ``pause`` ）

- 暂停或停止虚拟机
  
暂停虚拟机::

   virsh suspend ubuntu18.04

也可以停止虚拟机（ ``shutdown`` 或 ``destroy`` ）::

   virsh shutdown ubuntu18.04

- clone这个虚拟机，这里的案例是准备作为OpenStack开发测试虚拟机 ``devstack``  ::

   virt-clone --connect qemu:///system --original ubuntu18.04 --name devstack --file /var/lib/libvirt/images/devstack.qcow2

更为常用的命令是::

   virt-clone --original ubuntu18.04 --name devstack --auto-clone

这里使用 ``--auto-clone`` 参数可以自动处理 :ref:`libvirt_lvm_pool` ，非常方面实用

初始化虚拟机副本
==================

.. note::

   我在构建 :ref:`priv_cloud_infra` 环境中，由于只是个人使用的测试环境，所以没有执行 ``virt-sysprep`` ，此时需要手工修订的是主机名和IP地址，所有账号和内部设置都完全一致。 ``virt-clone`` 可以自动确保虚拟机的uuid和mac地址唯一，所以不会冲突。

- 使用 ``virt-sysprep`` 初始化虚拟机

重置虚拟机主机名和root用户账号（这里密码案例是 ``CHANGE_ME`` 请按需修改）::

   sudo virt-sysprep -d devstack --hostname devstack --root-password password:CHANGE_ME

.. note::

   ``virt-sysprep`` 命令行工具用于reset或unconfigure虚拟机。这个过程包括移除SSH host keys，移除持久化的网络MAC地址配置，以及清除用户账号。需要安装 ``libguestfs-tools`` 来获得 ``virt-sysprep`` 工具。

   暂时对 ``virt-sysprep`` 了解不透彻，后续在 :ref:`kvm` 补充详细用法。实际上这个工具可以帮助我们clone步骤自动化，可以省却这里对手工设置步骤。 - `How to reset a KVM clone virtual Machines with virt-sysprep on Linux <https://www.cyberciti.biz/faq/reset-a-kvm-clone-virtual-machines-with-virt-sysprep-on-linux/>`_

保留了账号 huatai/root 并且指定IP地址，避免重头开始::

   virt-sysprep -d z-pi-worker3 --hostname z-pi-worker3 \
       --run 'sed -i "s/192.168.122.42/192.168.122.251/" /etc/sysconfig/network-scripts/ifcfg-eth0' \
       --enable user-account --keep-user-accounts huatai --keep-user-accounts root

不过，实践发现网卡IP修改并不生效，还是需要手工订正 ``/etc/sysconfig/network-scripts/ifcfg-eth0`` ，需要订正MAC地址以及UUID。网卡的UUID我不确定，按照 `How to find out the uuid for eth0? <https://community.hpe.com/t5/Networking/How-to-find-out-the-uuid-for-eth0/td-p/5789983#.YWf9ttlBxqs>`_ 似乎是 ``uuidgen eth0`` 生成，每次都不相同。

启动虚拟机副本
=====================

- 启动虚拟机，进一步修改定制::

   virsh start devstack

- 在 ``xcloud`` 物理主机上通过串口命令连接虚拟机 ``devstack`` 使用密码登陆::

   virsh console devstack

- 重置虚拟机主机SSH key

``virt-sysprep`` 会清理掉原先模版虚拟机中所有账号的密钥，甚至主机的sshd的host密钥也被清理了，这会导致ssh无法登陆。所以这里会需要设置一次。

::

   ssh-keygen -A

- 定制libvirt静态分配虚拟机IP地址

.. note::

   由于libvirt的dnsmasq默认是动态分配虚拟机IP，但是对于一些服务虚拟机，需要能够使用静态IP地址，所以需要修改libvirt的默认网络。详细参考 :ref:`libvirt_static_ip_in_studio`

模拟物理服务器集群
====================

为了在笔记本环境中通过嵌套虚拟化模拟出多个物理服务器，在实验环境中，再次使用上述方法创建3个虚拟机来作为物理服务器使用>，为了区别，特意命名成 ``machine-1`` ， ``machine-2`` 和 ``machine-3`` ，这3个 L-1 虚拟机将完全视为物理服务器::

   for i in {1..3};do
       virt-clone --connect qemu:///system --original ubuntu18.04 --name machine-$i --file /var/lib/libvirt/images/machine-$i.qcow2
       sudo virt-sysprep -d machine-$i --hostname machine-$i --root-password password:CHANGE_ME
       virsh start machine-$i
   done

   virt-clone --connect qemu:///system --original ubuntu18.04 --name dockerstack --file /var/lib/libvirt/images/dockerstack.qcow2
   sudo virt-sysprep -d dockerstack --hostname dockerstack --root-password password:CHANGE_ME
   virsh start dockerstack

.. note::

   启动虚拟机之后，按照上述方法修订虚拟机配置并启用SSH服务，然后参考 :ref:`kvm_nested_virtual` 配置好用于进一步模拟集群的部署。

下一步
=============

目前我们得到的多个虚拟机是从模版中clone出来的，虽然我们能不断clone出虚拟机来模拟集群，但是默认clone出来的虚拟机只能作为guest来运行，在这样的虚拟机内部不能模拟物理服务器来运行虚拟化软件。接下来，我们要做一个非常关键的一步改造，把clone出来的虚拟机修改成能够嵌套运行虚拟机的虚拟机：

- :ref:`kvm_nested_virtual`
