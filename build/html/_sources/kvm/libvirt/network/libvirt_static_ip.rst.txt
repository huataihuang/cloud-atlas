.. _libvirt_static_ip_in_studio:

================================
Studio环境libvirt静态分配IP
================================

默认情况下libvirt内置的dnsmasq服务会动态分配IP地址给虚拟机，这导致每次启动的虚拟机IP地址可能不同。有部分作为固定服务的虚拟机IP地址期望不变，需要对libvirt的default网络做一些修改。

详细配置请参考 `KVM libvirt静态分配IP和端口转发 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/kvm_libvirt_static_ip_for_dhcp_and_port_forwarding.md>`_

这里没有采用配置dnsmasq的static DHCP方法，而是修改libvirt的DHCP的range，空出部分IP地址不分配，然后在虚拟机内部配置静态IP地址，这样更为简洁方便，


libvirt的DHCP分配范围调整
===========================

- 检查libvirt网络::

   virsh net-list

可以看到输出::

   Name                 State      Autostart     Persistent
   ----------------------------------------------------------
   default              active     yes           yes 

- 编辑默认网络::

   virsh net-edit default

将::

    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>

修改成::

    <dhcp>
      <range start='192.168.122.51' end='192.168.122.254'/>
    </dhcp>

这样，IP地址段 ``192.168.122.1 ~ 192.168.122.50`` 就不会动态分批，保留给固定IP地址使用。

- 重新生成libvirt网络::

   virsh  net-destroy default
   virsh  net-start default 

- 然后重新将虚拟机网络连接::

   brctl addif virbr0 vnet0
   brctl addif virbr0 vnet1
   ...

.. note::

   Host主机 ``/var/lib/libvirt/dnsmasq/virbr0.status`` 提供了当前dnsmasq分配的IP地址情况。

配置Ubuntu虚拟机的静态IP
==========================

对于Kubernetes master等服务器，我期望IP地址是固定的IP地址，所以准备配置static IP。不过，Ubuntu 18系列的静态IP地址配置方法和以前传统配置方法不同，采用了 ``.yaml`` 配置文件，通过 ``netplan`` 网络配置工具来修改。

请参考 :ref:`netplan_static_ip`

依次对必要的测试虚拟机调整静态IP，调整后的IP地址见 :ref:`studio_ip` 。

下一步
==============
