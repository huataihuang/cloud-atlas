.. _priv_kvm_sr-iov:

===========================
私有云KVM网络虚拟化sr-iov
===========================

现在 :ref:`zdata_ceph` 是直接在 :ref:`priv_kvm` 上部署 :ref:`ceph` ，其他KVM虚拟机都采用 :ref:`zdata_ceph_rbd_libvirt` 部署，运行在分布式存储上。这部分运行在分布式存储上的VM，将部署 :ref:`openstack` 和 :ref:`kubernetes` ，所以，网络服务非常关键，将模拟大规模云计算的网络优化，采用 :ref:`sr-iov` 技术，获得接近于物理网卡硬件性能。

虽然通过手工方式 :ref:`config_sr-iov_network` 清晰简洁，但是对于大规模云计算(我计划在物理主机上运行数十到上百虚拟机)，手工配置效率还是很低下的。所以，采用 :ref:`libvirt_network_pool_sr-iov` 实现SR-IOV虚拟网卡VF的自动分配和回收。

内核配置
===========

- 修订 ``/etc/default/grub`` 配置添加 ``intel_iommu=on iommu=pt`` 参数，类似::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on iommu=pt vfio-pci.ids=144d:a80a,10de:1b39"

- 更新grub::

   sudo update-grub

- 决定Intel网卡SR-IOV配置多少VF是由 ``igb`` 模块的参数决定，可以手工配置(以下案例是 ``eno49`` ，对应4口Intel I350网卡的第一个网口)::

   echo 7 | sudo tee /sys/class/net/eno49/device/sriov_numvfs

但是更好的标准配置方法是采用dbus，所以修订 ``/etc/udev/rules.d/igb.rules`` ::

   ACTION=="add", SUBSYSTEM=="net", ENV{ID_NET_DRIVER}=="igb", ATTR{device/sriov_numvfs}="7"

- 在系统中添加一个 :ref:`netplan` 配置 ``/etc/netplan/02-eno49-config.yaml`` ，自动激活需要添加VF的PF设备 ``eno49`` ，必须确保PF激活才能使用VF:

.. literalinclude:: ../../kvm/sr-iov/libvirt_network_pool_sr-iov/02-eno49-config.yaml
   :language: xml
   :linenos:
   :caption: netplan激活eno49但不分配IP的方法

- 重启系统使内核参数生效，并且 ``igb`` 驱动属性 ``sriov_numvfs`` 设置为 ``7`` ，即启用7个VF。重启后检查::

   lspci | grep -i i350

可以看到每个物理网卡(4口I350，对应 ``eno49`` 到 ``eno52`` )都分配了7个VF

创建SR-IOV虚拟网络资源池
==========================

- 网络资源池配置:

.. literalinclude:: ../../kvm/sr-iov/libvirt_network_pool_sr-iov/eno49-sr-iov.xml
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

.. literalinclude:: ../../kvm/sr-iov/libvirt_network_pool_sr-iov/vm-sr-iov.xml
   :language: xml
   :linenos:
   :caption: 配置虚拟机sr-iov设备xml

- 添加设备::

   virsh attach-device z-k8s-n-1 vm-sr-iov.xml --config

上述 ``virsh attach-device`` 命令会在 ``z-k8s-n-1`` 虚拟机中添加一块SR-IOV网卡 (在虚拟机内部显示为 ``ens1``

.. note::

   要在虚拟机内部添加几块VF网卡，就执行上述 ``virsh attach-device`` 命令几次。但是需要注意，系统中同时启动的VM使用的VF总数不能超过PF能否分配的 ``sriov_numvfs`` 数量，否则会导致虚拟机无法启动。

- 修订 ``/etc/apparmor.d/abstractions/libvirt-qemu`` ，将::

   # for vfio hotplug on systems without static vfio (LP: #1775777)
   /dev/vfio/vfio rw,

修改成::

   /dev/vfio/* rw,

.. note::

   修订 ``libvirt-qemu`` 配置可以让 ``libvirt`` 修订 ``/dev/vfio/vfio*`` 设备权限，否则会导致虚拟机启动时无法打开设备。

- 启动虚拟机::

   virsh start z-k8s-n-1

启动后，登陆虚拟机内部检查::

   ifconfig -a

可以看到除了之前 :ref:`priv_kvm` 分配的 ``virtio-net`` 虚拟网卡 ``enp1s0`` 之外，有4个 ``ens1`` 到 ``ens4`` 网卡，是SR-IOV的VF (执行了4次 ``virsh attach-device`` 添加了4块VF)
