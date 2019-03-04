.. _clone_vm_in_studio:

==========================
Studio环境复制KVM虚拟机
==========================

为了能够在模拟环境中快速创建KVM虚拟机，需要将 :ref:`create_vm_in_studio` 首个ubuntu虚拟机作为模版，快速clone出需要的部署集群所需虚拟机。

.. note::

   详细操作可以参考 `Clone KVM虚拟机实战 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/clone_kvm_vm_in_action.md>`_ 

   克隆虚拟机之前，被克隆的虚拟机需要处于停机状态或者暂停状态（ ``pause`` ）

- 暂停或停止虚拟机
  
暂停虚拟机::

   virsh suspend ubuntu18.04

也可以停止虚拟机（ ``shutdown`` 或 ``destroy`` ）::

   virsh shutdown ubuntu18.04

- 配置模版虚拟机的 ``setmaxmem`` 和手工修改配置，以便后续能够根据需要动态修改虚拟机的vcpu和mem::

   virsh setmaxmem ubuntu18.04 16G

不过，设置最大vcpu数量方法没有直接的virsh命令，所以采用 ``virsh edit kube-master1`` 方法，将以下配置::

   <vcpu placement='static'>1</vcpu>

修改成::

   <vcpu placement='static' current='1'>8</vcpu>

.. note::

   详细的动态修改虚拟机vcpu和memory的方法参考 `动态调整KVM虚拟机内存和vcpu实战 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/add_remove_vcpu_memory_to_guest_on_fly.md>`_

- clone这个虚拟机，这里的案例是kubernetes的master节点 kube-master1 ::

   virt-clone --connect qemu:///system --original ubuntu18.04 --name kube-master1 --file /var/lib/libvirt/images/kube-master1.qcow2

- 使用 ``virt-sysprep`` 初始化虚拟机

.. note::

   ``virt-sysprep`` 命令行工具用于reset或unconfigure虚拟机。这个过程包括移除SSH host keys，移除持久化的网络MAC地址配置，以及清除用户账号。需要安装 ``libguestfs-tools`` 来获得 ``virt-sysprep`` 工具。

重置虚拟机主机名和root用户账号（这里密码案例是 ``CHANGE_ME`` 请按需修改）::

   virt-sysprep -d kube-master1 --hostname kube-master1 --root-password password:CHANGE_ME


- 启动虚拟机，进一步修改定制

``virt-sysprep`` 会清理掉原先模版虚拟机中所有账号的密钥，甚至主机的sshd的host密钥也被清理了，这会导致ssh无法登陆。所以这里会需要设置一次。

::

   ssh-keygen -A

- 定制libvirt静态分配虚拟机IP地址

.. note::

   由于libvirt的dnsmasq默认是动态分配虚拟机IP，但是对于一些服务虚拟机，需要能够使用静态IP地址，所以需要修改libvirt的默认网络。详细参考 :ref:`libvirt_static_ip_in_studio`
