.. _libvirt_network_pool_sr-iov:

=============================
Libvirt管理SR-IOV虚拟网络池
=============================

:ref:`libvirt` 是管理虚拟设备和hypervisor的API及服务，也提供了一种通过创建虚拟网络资源池的方式来管理VF，不需要像 :ref:`config_sr-iov_network` 复杂的对PCI设备ID进行查询和配置，只需要提供一个物理网卡设备( ``PF`` )给libivrt，然后在KVM创建时引用这个虚拟网卡资源池就可以自动分配VF。

准备
=======

和 :ref:`config_sr-iov_network` 一样，首先需要确保内核已经激活启用 :ref:`iommu` ，也就是内核配置::

   intel_iommu=on iommu=pt

配置方法参见 :ref:`config_sr-iov_network` 

- 激活 VF::

   for i in {0..3};do
       n=$[49+$i]
       # 激活VF eno49 ~ eno52
       echo 7 | sudo tee /sys/class/net/eno${n}/device/sriov_numvfs
   done

- 设置启动操作系统时自动激活VF:

虽然可以如 :ref:`config_sr-iov_network` 中所述，采用命令行(或者启动 ``/etc/rc.d/rc.local`` )来激活。但是，在启动操作系统时候自动配置设备的标准且推荐方法是采用 :ref:`udev` (毕竟运维工作是一个标准化协作过程)，所以，配置 ``/etc/udev/rules.d/igb.rules`` ::

   ACTION=="add", SUBSYSTEM=="net", ENV{ID_NET_DRIVER}=="igb", ATTR{device/sriov_numvfs}="7"

这样操作系统启动时，使用 ``igb`` 驱动的网卡(4口Intel I350)都会配置VF

- 检查VF::

   lspci | grep -i i350

可以看到::

   04:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.2 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:00.3 Ethernet controller: Intel Corporation I350 Gigabit Network Connection (rev 01)
   04:10.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.1 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.2 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.3 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.4 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.5 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.6 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:10.7 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   04:11.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)
   ...

- 验证设备详情

物理网卡 ``eno49`` 对应的 PCI 设备ID 是 ``04:00.0`` ，通过 ``virsh nodedev-list | grep 04_00_0`` 可以看到::

   pci_0000_04_00_0

这个设备在virsh管理中就是物理网卡，我们可以通过命令查看::

   virsh nodedev-dumpxml pci_0000_04_00_0

输出会显示PF以及对应所有VF:

.. literalinclude:: libvirt_network_pool_sr-iov/virsh_node-dumpxml_pci_0000_04_00_0.xml
   :language: xml
   :linenos:
   :caption: virsh nodedev-dumpxml pci_0000_04_00_0 检查SR-IOV的PF及所有VF

我们也可以检查VF ，例如第一个VF ``<address domain='0x0000' bus='0x04' slot='0x10' function='0x0'/>`` ::

   virsh nodedev-dumpxml pci_0000_04_10_0

输出这个VF的相信信息:

.. literalinclude:: libvirt_network_pool_sr-iov/virsh_node-dumpxml_pci_0000_04_10_0.xml
   :language: xml
   :linenos:
   :caption: virsh nodedev-dumpxml pci_0000_04_10_0 检查指定VF

较为复杂的VF添加
------------------

添加VF时可以指定VLAN，例如:

.. literalinclude:: libvirt_network_pool_sr-iov/eno49vf0-vlan.xml
   :language: xml
   :linenos:
   :caption: 配置VF的VLAN等复杂案例

然后添加到虚拟机::

   virsh attach-device MyGuest eno49vf0-vlan.xml --live --config

创建SR-IOV虚拟网络资源池
==========================

使用硬编码配置PCI地址方式VF有2个缺陷:

- 当guest虚拟机启动时，特定VF必须可用: 这对管理员来说非常麻烦，需要指定每个VF和每个指定虚拟机
- 如果虚拟机被迁移到另外一台物理主机，则另一台物理服务器必须在PCI总线相同位置有相同的硬件，否则虚拟机配置必须修改后才能启动

为了解决上述问题，通过创建一个libvirt网络设备池来包含一个SR-IOV设备的所有VF。只要配置guest虚拟机引用这个网络，每次启动虚拟机，一个VF就会从资源池分配给虚拟机。一旦虚拟机停止，VF就会返回资源池用于另一个虚拟机。

- 网络资源池配置:

.. literalinclude:: libvirt_network_pool_sr-iov/eno49-sr-iov.xml
   :language: xml
   :linenos:
   :caption: 配置eno49网卡的VF网络资源池

- 加载网络资源池定义::

   virsh net-define eno49-sr-iov.xml

- 配置定义的网络自动启动::

   virsh net-autostart eno49-sr-iov

- 启动 ``eno49-sr-iov`` 网络资源池::

   virsh net-start eno49-sr-iov

然后检查::

   virsh net-list

可以看到::

   Name           State    Autostart   Persistent
   -------------------------------------------------
   default        active   yes         yes
   eno49-sr-iov   active   yes         yes

通过libvirt网络资源池分配VF给VM
=================================

- 配置 ``vm-sr-iov.xml`` :

.. literalinclude:: libvirt_network_pool_sr-iov/vm-sr-iov.xml
   :language: xml
   :linenos:
   :caption: 配置虚拟机sr-iov设备xml

- 添加设备::

   virsh attach-device z-k8s-n-1 vm-sr-iov.xml --config

检查虚拟机设备::

   virsh dumpxml z-k8s-n-1

可以看到虚拟机添加了一段网络设备配置::

     <interface type='network'>
       <mac address='52:54:00:59:50:09'/>
       <source network='eno49-sr-iov'/>
       <model type='rtl8139'/>
       <address type='pci' domain='0x0000' bus='0x08' slot='0x01' function='0x0'/>
     </interface>

奇怪，怎么显示是 ``type='rtl8139'`` ，并且地址也和之前VF不同？

- 启动虚拟机::

   virsh start z-k8s-n-1

提示报错::

   error: Failed to start domain z-k8s-n-1
   error: internal error: qemu unexpectedly closed the monitor: 2021-12-18T15:13:32.733835Z qemu-system-x86_64: -device vfio-pci,host=0000:04:10.0,id=hostdev0,bus=pci.8,addr=0x1: vfio 0000:04:10.0: failed to open /dev/vfio/94: Permission denied

这里可以看出，其实 ``vfio`` 映射还是访问 ``vfio 0000:04:10.0`` 也就是VF设备

但是，为何没有权限?我尝试了加上 ``sudo`` 也是同样报错

在 ``/var/log/libvirt/qemu/z-k8s-n-1.log`` 中有日志记录::

   2021-12-18T15:36:17.735032Z qemu-system-x86_64: -device vfio-pci,host=0000:04:10.0,id=hostdev0,bus=pci.8,addr=0x1: vfio 0000:04:10.0: failed to open /dev/vfio/94: Permission denied
   2021-12-18 15:36:17.858+0000: shutting down, reason=failed

在 `Bug 1196185 - libvirt doesn't set permissions for VFIO endpoint <https://bugzilla.redhat.com/show_bug.cgi?id=1196185>`_ 说明::

   RHEV by default sets dynamic_ownership=0, which caused the endpoint not to be accessible by qemu (and we explicitly told libvirt not to do it for us). Works with dynamic_ownership=1.

我检查了 ``/etc/libvirt/qemu.conf`` 有这个配置::

   # Whether libvirt should dynamically change file ownership
   # to match the configured user/group above. Defaults to 1.
   # Set to 0 to disable file ownership changes.
   #dynamic_ownership = 1

看起来默认就是 ``1``

检查host主机 ``ls -lh /dev/vfio/*`` 输出是::

   crw------- 1 root root 243,   0 Dec 16 09:20 /dev/vfio/39
   crw------- 1 root root 243,   1 Dec 16 09:20 /dev/vfio/40
   crw------- 1 root root 243,   2 Dec 16 09:20 /dev/vfio/41
   crw------- 1 root root 243,   3 Dec 16 09:20 /dev/vfio/79
   crw-rw-rw- 1 root root  10, 196 Dec 16 09:20 /dev/vfio/vfio

并没有看到设备 ``/dev/vfio/94`` 这个设备

参考
=======

- `Configure SR-IOV Network Virtual Functions in Linux KVM <https://www.intel.com/content/www/us/en/developer/articles/technical/configure-sr-iov-network-virtual-functions-in-linux-kvm.html>`_
- `Red Hat Enterprise Linux > 7 > Virtualization Deployment and Administration Guide > 16.2. PCI Device Assignment with SR-IOV Devices <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-pci_devices-pci_passthrough>`_ 
