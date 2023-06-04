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

vfio权限问题
================

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

- 尝试重启操作系统，重启操作系统后执行::

   virsh start z-k8s-n-1

提示报错::

   error: Failed to start domain z-k8s-n-1
   error: internal error: Unable to configure VF 0 of PF 'eno49' because the PF is not online. Please change host network config to put the PF online.

- 检查 ``ifconfig -a | grep eno`` 输出显示网卡PF ( ``eno49`` 到 ``eno52`` )确实没有激活( ``UP`` )::

   ...
   eno49: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   ...
   eno49v0: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v1: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   ...

那么，如何能够自动激活 ``eno49`` 同时不分配IP地址呢？ 参考 `Bring up but don't assign address with Netplan <https://askubuntu.com/questions/1037276/bring-up-but-dont-assign-address-with-netplan>`_ 配置 ``/etc/netplan/02-eno49-config.yaml`` 

.. literalinclude:: libvirt_network_pool_sr-iov/02-eno49-config.yaml
   :language: xml
   :linenos:
   :caption: netplan激活eno49但不分配IP的方法

然后执行::

   sudo netplan apply

此时 ``ifconfig -a | grep eno`` ::

   ...
   eno49: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
   eno49v0: flags=4098<BROADCAST,MULTICAST>  mtu 1500
   eno49v1: flags=4098<BROADCAST,MULTICAST>  mtu 1500

Ok，解决了 ``eno49`` 的 ``UP`` 问题，依然在 ``virsh start z-k8s-n-1`` 遇到报错::

   error: Failed to start domain z-k8s-n-1
   error: internal error: qemu unexpectedly closed the monitor: 2021-12-19T15:12:47.375350Z qemu-system-x86_64: -device vfio-pci,host=0000:04:10.0,id=hostdev0,bus=pci.8,addr=0x1: vfio 0000:04:10.0: failed to open /dev/vfio/96: Permission denied

我找到两种可能解决方法:

- `Permission denied when using vfio with interface pools <https://bugs.launchpad.net/ubuntu/+source/libvirt/+bug/1840552>`_ 

提供的解决方法是修订 ``/etc/apparmor.d/abstractions/libvirt-qemu`` ( ``bionic`` 版本)，或者在更高版本，修订覆盖配置文件 ``/etc/apparmor.d/local/abstractions/libvirt-qemu`` ，将::

   # for vfio hotplug on systems without static vfio (LP: #1775777)
   /dev/vfio/vfio rw,

修改成::

   /dev/vfio/* rw,

由于我是最新版本，所以我在 ``/etc/apparmor.d/local/abstractions/libvirt-qemu`` 添加了一行::

   /dev/vfio/* rw,

然后就可以正常启动虚拟机

- `failed to open /dev/vfio/13: Permission denied <https://www.reddit.com/r/VFIO/comments/bveihq/failed_to_open_devvfio13_permission_denied/>`_ 提供了另一中解决思路，就是添加一个 :ref:`udev` 规则::

   SUBSYSTEM=="vfio", OWNER="root", GROUP="kvm"

这样所有的vfio设备都会被qemu读写。这个思路应该可行，不过我没有实践

虚拟机检查
============

正确启动虚拟机之后，登陆 ``z-k8s-n-1`` 检查网卡::

   $ lspci | grep -i eth

可以看到有2个ethernet设备::

   01:00.0 Ethernet controller: Red Hat, Inc. Virtio network device (rev 01)
   07:01.0 Ethernet controller: Intel Corporation I350 Ethernet Controller Virtual Function (rev 01)

其中有一个是 ``Intel I350`` 的 VF设备

- 检查网卡::

   ip addr

看到::

   2: ens1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:2b:4e:d3 brd ff:ff:ff:ff:ff:ff
   3: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 52:54:00:ff:37:67 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.111/24 brd 192.168.6.255 scope global enp1s0
          valid_lft forever preferred_lft forever
       inet6 fe80::5054:ff:feff:3767/64 scope link
          valid_lft forever preferred_lft forever   

根据 ``virsh dumpxml z-k8s-n-1`` 输出有关 ::

     <interface type='network'>
       <mac address='52:54:00:2b:4e:d3'/>
       <source network='eno49-sr-iov'/>
       <model type='rtl8139'/>
       <address type='pci' domain='0x0000' bus='0x08' slot='0x01' function='0x0'/>
     </interface>

可以知道 ``ens1`` 就是 ``SR-IOV`` 设备

注入多块 ``SR-IOV``
=====================

规划在一个虚拟机中注入4个 ``SR-IOV`` 网卡，作为后续Kubernetes节点容器使用，所以对该虚拟机再次执行::

   virsh attach-device z-k8s-n-1 vm-sr-iov.xml --live --config

然后检查 ``virsh dumpxml z-k8s-n-1`` ，果然，具备了第二块SR-IOV网卡::

     <interface type='network'>
       <mac address='52:54:00:2b:4e:d3'/>
       <source network='eno49-sr-iov'/>
       <model type='rtl8139'/>
       <address type='pci' domain='0x0000' bus='0x08' slot='0x01' function='0x0'/>
     </interface>
     <interface type='network'>
       <mac address='52:54:00:47:82:9e'/>
       <source network='eno49-sr-iov'/>
       <model type='rtl8139'/>
       <address type='pci' domain='0x0000' bus='0x08' slot='0x02' function='0x0'/>
     </interface>

此时，在虚拟机内部检查::

   2: ens1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:2b:4e:d3 brd ff:ff:ff:ff:ff:ff
   3: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 52:54:00:ff:37:67 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.111/24 brd 192.168.6.255 scope global enp1s0
          valid_lft forever preferred_lft forever
       inet6 fe80::5054:ff:feff:3767/64 scope link
          valid_lft forever preferred_lft forever
   4: enp8s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:47:82:9e brd ff:ff:ff:ff:ff:ff

但是，再注入第3块SR-IOV::

   virsh attach-device z-k8s-n-1 vm-sr-iov.xml --live --config

报错::

   error: Failed to attach device from vm-sr-iov.xml
   error: internal error: No more available PCI slots

这个问题参考 `libvirtd: No more available PCI slots <https://unix.stackexchange.com/questions/570166/libvirtd-no-more-available-pci-slots>`_ ，去掉 ``--live`` 参数，只修改配置，然后重新启动虚拟机，此时libvirt会自动添加所需的pcie-root-port

按照上述建议方法，我再重复执行2次::

   virsh attach-device z-k8s-n-1 vm-sr-iov.xml --config

然后确保 ``z-k8s-n-1`` 中具备了4个SR-IOV设备配置，然后重新启动虚拟机，登陆虚拟机就可以看到虚拟机除了一块 virtio-net 虚拟网卡，还添加了4块 ``SR-IOV`` 网卡::

   2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
       link/ether 52:54:00:ff:37:67 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.111/24 brd 192.168.6.255 scope global enp1s0
          valid_lft forever preferred_lft forever
       inet6 fe80::5054:ff:feff:3767/64 scope link
          valid_lft forever preferred_lft forever
   3: ens1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:2b:4e:d3 brd ff:ff:ff:ff:ff:ff
   4: ens2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:47:82:9e brd ff:ff:ff:ff:ff:ff
   5: ens3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:ed:e4:a3 brd ff:ff:ff:ff:ff:ff
   6: ens4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
       link/ether 52:54:00:16:55:cf brd ff:ff:ff:ff:ff:ff

- 在 ``z-k8s-n-2`` 上我也采用上述方法执行4次::

   virsh attach-device z-k8s-n-2 vm-sr-iov.xml --config
   virsh attach-device z-k8s-n-2 vm-sr-iov.xml --config
   virsh attach-device z-k8s-n-2 vm-sr-iov.xml --config
   virsh attach-device z-k8s-n-2 vm-sr-iov.xml --config

但是启动 ``virsh start z-k8s-n-2`` 报错::

   error: Failed to start domain z-k8s-n-2
   error: internal error: network 'eno49-sr-iov' requires exclusive access to interfaces, but none are available

原因是 ``Intel I350`` 网卡，也就是 ``igb`` 只支持7个VF，另外一个是PF不能添加到虚拟机内部，所以，对于第二台虚拟机，最多只能添加3个SR-IOV VF。

``virsh edit z-k8s-n-2`` 去除掉第4个添加的VF，就能正常启动了。

参考
=======

- `Configure SR-IOV Network Virtual Functions in Linux KVM <https://www.intel.com/content/www/us/en/developer/articles/technical/configure-sr-iov-network-virtual-functions-in-linux-kvm.html>`_
- `Red Hat Enterprise Linux > 7 > Virtualization Deployment and Administration Guide > 16.2. PCI Device Assignment with SR-IOV Devices <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-pci_devices-pci_passthrough>`_ 
