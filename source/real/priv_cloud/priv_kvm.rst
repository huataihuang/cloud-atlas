.. _priv_kvm:

=======================
私有云KVM环境
=======================

环境准备
=========

内核和KVM虚拟化
-----------------

- 物理服务器: :ref:`hpe_dl360_gen9`

- 物理主机内核启用 :ref:`iommu` 并采用 :ref:`ovmf` 方式将NVMe设备( :ref:`samsung_pm9a1` 对应ID是 ``144d:a80a`` )绑定到 ``vfio-pci`` 内核模块: 修改 ``/etc/default/grub`` ::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on vfio-pci.ids=144d:a80a"

.. note::

   这里 :ref:`samsung_pm9a1` 的ID通过命令::

      lspci -nn | grep -i samsung

   可以获得::

      05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
      ...

   所有相同型号NVMe都共用一个设备ID ``144d:a80a``

然后修正grub并重启::

   sudo update-grub
   shutdown -r now

- 按照 :ref:`ubuntu_deploy_kvm` 安装部署好基础KVM运行环境::

   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst

   sudo adduser `id -un` libvirt
   sudo adduser `id -un` kvm

- 然后确认运行环境正常::

   $ virsh list --all
    Id    Name                           State
   ----------------------------------------------------

NVMe存储pass-through
----------------------

在模拟大规模云计算平台的分布式存储 :ref:`ceph` 需要高性能NVMe存储通过 :ref:`iommu` pass-through 给虚拟机，以构建高速存储架构。要实现PCIe pass-through，需要采用 :ref:`ovmf` 模式的KVM虚拟机

- 检查需要 ``pass-through`` 的NVMe设备( ``samsung`` 存储 )::

   lspci -nn | grep -i Samsung

输出显示通过 :ref:`pcie_bifurcation` 安装到 :ref:`hpe_dl360_gen9` 一共有3块 :ref:`samsung_pm9a1` ::

   05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   08:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   0b:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]

- ``144d:a80a`` 代表 :ref:`samsung_pm9a1` 需要传递给内核绑定到 ``vfio-pci`` 模块上，同时需要增加 ``intel_iommu=on`` 内核参数激活 :ref:`iommu` (也就是 Intel vt-d 技术)，所以修订 ``/etc/default/grub`` 添加配置::

   GRUB_CMDLINE_LINUX_DEFAULT="intel_iommu=on vfio-pci.ids=144d:a80a"

并更新grub::

   sudo update-grub

重启操作系统使内核新参数生效，重启后检查内核参数::

   cat /proc/cmdline

可以看到::

   BOOT_IMAGE=/boot/vmlinuz-5.4.0-90-generic root=UUID=caa4193b-9222-49fe-a4b3-89f1cb417e6a ro intel_iommu=on vfio-pci.ids=144d:a80a

- 检查内核模块 ``vfio-pci`` 是否已经绑定了 NVMe 设备::

   lspci -nnk -d 144d:a80a

应该看到如下表明3个NVMe设备都已经绑定内核驱动 ``vfio-pci`` ::

   05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   	Subsystem: Samsung Electronics Co Ltd Device [144d:a801]
   	Kernel driver in use: vfio-pci
   	Kernel modules: nvme
   08:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   	Subsystem: Samsung Electronics Co Ltd Device [144d:a801]
   	Kernel driver in use: vfio-pci
   	Kernel modules: nvme
   0b:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   	Subsystem: Samsung Electronics Co Ltd Device [144d:a801]
   	Kernel driver in use: vfio-pci
   	Kernel modules: nvme   

LVM卷作为libvirt存储
------------------------

- 物理主机 ``/dev/sda`` 是Intel SSD 512G，分区4作为LVM卷::

   /dev/sda4  458983424 1000214527 541231104 258.1G Linux LVM

- 执行 :ref:`libvirt_lvm_pool` 中卷管理并加入libvirt作为存储::

   pvcreate /dev/sda4
   vgcreate vg-libvirt /dev/sda4

   virsh pool-define-as images_lvm logical --source-name vg-libvirt --target /dev/sda4
   virsh pool-start images_lvm
   virsh pool-autostart images_lvm

- 在每次创建VM之前，首先创建对应卷::

   virsh vol-create-as images_lvm VM 6G

然后创建虚拟机(详见下文)::

   virt-install ... \
   ...
     --boot uefi --cpu host-passthrough \
     --disk path=/dev/vg-libvirt/VMNAME,sparse=false,format=raw,bus=virtio,cache=none,io=native \
   ...

- 如果已经创建了模板虚拟机，则使用 ``virt-clone`` 命令clone出(无需手工准备LVM卷)::

   virt-clone --original TEMPLATE-VM --name NEW-VM --auto-clone

- 删除VM::

   virsh undefine --nvram VM --remove-all-storage

如果没有使用 ``--remove-all-storage`` 则虚拟机删除并不删除卷，可以独立使用命令::

   virsh vol-delete VMNAME-VOL images_lvm

这里 ``VMNAME-VOL`` 是虚拟机卷， ``images_lvm`` 是创建的LVM卷存储池名字

设置交换网络
----------------

虽然在测试环境中，我们常常使用 :ref:`libvirt_nat_network` ，但是我在部署 :ref:`hpe_dl360_gen9` 和 :ref:`pi_cluster` 是通过物理交换机连接的，也就是说，所有数据通讯都是通过真实网络传输，所以我们需要采用 :ref:`libvirt_bridged_network` :

- 通讯通过DL360服务器的 ``eno1`` 网口，网段是 ``192.168.6.0/24`` ::

   ip address show eno1

显示::

   2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
       link/ether 94:57:a5:5a:d9:c0 brd ff:ff:ff:ff:ff:ff
       inet 192.168.6.200/24 brd 192.168.6.255 scope global eno1
          valid_lft forever preferred_lft forever
       inet6 fe80::9657:a5ff:fe5a:d9c0/64 scope link
          valid_lft forever preferred_lft forever

- 创建 ``/etc/sysctl.d/bridge.conf`` 以下设置(性能和安全原因)::

   net.bridge.bridge-nf-call-ip6tables=0
   net.bridge.bridge-nf-call-iptables=0
   net.bridge.bridge-nf-call-arptables=0

配置生效::

   sysctl -p /etc/sysctl.d/bridge.conf

- 创建 ``/etc/udev/rules.d/99-bridge.rules`` ，这个udev规则将在加载bridge模块式执行上述sysctl规则::

   ACTION=="add", SUBSYSTEM=="module", KERNEL=="bridge", RUN+="/sbin/sysctl -p /etc/sysctl.d/bridge.conf"

.. warning::

   上述设置 ``net.bridge.bridge-nf-call-iptables=0`` 等3条内核规则非常重要，如果没有关闭，则会出现非常奇怪的现象:

   - 物理主机能够访问bridged的虚拟机，虚拟机也能通过br0访问外网
   - ``但是`` 连接在 ``br0`` 上的各个虚拟机相互之间网络不通

.. note::

   实现bridge网络有多种方法，为了和Ubuntu Server默认的 :ref:`netplan` 管理方法一致，这里采用 netplan 来实现bridge

- 配置 ``/etc/netplan/00-cloud-init.yaml``

.. literalinclude:: ../../kvm/libvirt/network/libvirt_bridged_network/00-cloud-init.yaml
   :language: yaml
   :linenos:
   :caption: /etc/netplan/00-cloud-init.yaml

执行生效::

   sudo netplan generate
   sudo netplan apply

创建模版虚拟机
===================

.. note::

   注意，如果是普通用户执行 ``virt-install`` 会提示错误::

      WARNING  /home/huatai/.cache/virt-manager/boot may not be accessible by the hypervisor. You will need to grant the 'libvirt-qemu' user search permissions for the following directories: ['/home/huatai/.cache']

   需要修复这个权限才能正常安装::

      chmod 770 ~/.cache
      sudo adduser libvirt-qemu staff

   不过还是报错::

      [  219.477216 ] dracut-initqueue[736]: Warning: dracut-initqueue timeout - starting timeout scripts

- 安装 ``libosinfo-bin`` 就可以使用 ``osinfo-query --os-variant`` 查询可以支持的操作系统类型

.. note::

   为了能够优化虚拟机存储性能，我采用 :ref:`libvirt_lvm_pool` 作为虚拟存储(物理主机没有文件系统层)

   我主要使用3种操作系统:

   - Ubuntu 20.04.3 - 主要虚拟机操作系统，用于部署 :ref:`openstack` 以及 :ref:`kubernetes` 运行环境
   - Fedora 35 - 开发用途的操作系统
   - CentOS 8 - 用于Red Hat系列应用部署，例如 :ref:`ovirt` 和 :ref:`gluster` 运行环境

Fedora35虚拟机模板
--------------------

- 创建模板虚拟机 Fedora 35 (详见 :ref:`ovmf` )::

   virsh vol-create-as images_lvm z-fedora35 6G

   virt-install \
     --network bridge:virbr0 \
     --name z-fedora35 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=Linux --os-variant=fedora31 \
     --boot uefi --cpu host-passthrough \
     --disk path=/dev/vg-libvirt/z-fedora35,sparse=false,format=raw,bus=virtio,cache=none,io=native \
     --graphics none \
     --location=http://mirrors.163.com/fedora/releases/35/Server/x86_64/os/ \
     --extra-args="console=tty0 console=ttyS0,115200"

- Fedora使用 :ref:`networkmanager` 管理网络，所以登录虚拟机配置静态IP地址和主机名::

   nmcli general hostname z-fedora35
   nmcli connection modify "enp1s0" ipv4.method manual ipv4.address 192.168.6.244/24 ipv4.gateway 192.168.6.200 ipv4.dns "192.168.6.200,192.168.6.11"   

- 配置用户帐号 :ref:`ssh` 密钥认证登录

- 结合 :ref:`apt_proxy_arch` 配置虚拟机使用代理服务器更新系统，设置 :ref:`dnf` 代理配置 ``/etc/dnf/dnf.conf`` 添加::

   proxy=http://192.168.6.200:3128

.. note::

   请注意，这里 ``--network bridge:virbr0`` 是使用了 :ref:`libvirt_nat_network` ，而没有直接使用前面创建的的 :ref:`libvirt_bridged_network` ``br0`` ，这是因为发现初次安装guest内部内核还是需要访问internet，否则会出现报错 :ref:`dracut-initqueue_timeout` 。

   模版操作系统通过NAT方式完成安装，再clone出来的虚拟机连接Bridge网络，则可以通过设置 :ref:`apt_proxy_arch` 完成后续更新和部署。

- clone基于Fedora 35的虚拟机( ``z-dev`` )::

   virt-clone --original z-fedora35 --name z-dev --auto-clone 

- 修订 ``z-dev`` 配置( ``2c4g`` )然后启动::

   virsh edit z-dev
   virsh start z-dev

- 登录 ``z-dev`` 控制台， 修订主机名和IP::

   nmcli general hostname z-dev
   nmcli connection modify "enp1s0" ipv4.method manual ipv4.address 192.168.6.253/24 ipv4.gateway 192.168.6.200 ipv4.dns "192.168.6.200,192.168.6.11"   

Ubuntu20虚拟机模板
------------------------

- 创建模板虚拟机 Ubuntu 20.04.3 (详见 :ref:`ovmf` )::

   virsh vol-create-as images_lvm z-ubuntu20 6G

   virt-install \
     --network bridge:br0 \
     --name z-ubuntu20 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=ubuntu20.04 \
     --boot uefi --cpu host-passthrough \
     --disk path=/dev/vg-libvirt/z-ubuntu20,sparse=false,format=raw,bus=virtio,cache=none,io=native \
     --graphics none \
     --location=http://mirrors.163.com/ubuntu/dists/focal/main/installer-amd64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

.. note::

   这里直接使用了 :ref:`libvirt_bridged_network` 中配置的 ``br0`` ，是因为Ubuntu在安装过程中可以设置代理服务器，而我已经采用 :ref:`apt_proxy_arch` 部署了 :ref:`squid` 作为代理

.. note::

   一定要使用 ``--boot uefi --cpu host-passthrough`` 参数激活 :ref:`ovmf` ，否则虽然能够 ``pass-through`` PCIe设备给虚拟机，但是虚拟机无法使用完整的物理主机CPU特性，而是使用虚拟出来的CPU，性能会损失。

正确实现 ``--boot uefi --cpu host-passthrough`` 后，在虚拟机内部有以下2个特征:

  - CPU显示和物理服务器一致::

     cat /proc/cpuinfo

可以看到::

   ...
   model name: Intel(R) Xeon(R) CPU E5-2670 v3 @ 2.30GHz    
   
  - ``/boot/efi`` 目录独立分区，且存储了 ``EFI`` 相关配置和数据

- :ref:`ubuntu_vm_console` 默认不输出，所以安装完成(配置了ssh服务)，通过ssh登录到虚拟机修订 ``/etc/default/grub`` 配置::

   GRUB_CMDLINE_LINUX="console=ttyS0,115200"
   GRUB_TERMINAL="serial console"
   GRUB_SERIAL_COMMAND="serial --speed=115200"

更新grub::

   sudo update-grub

重启以后 ``virsh console z-ubuntu20`` 就能正常工作，方便运维。

- 修订虚拟机 ``/etc/sudoers`` 将自己的管理帐号所在 ``sudo`` 组设置为无密码执行命令(个人使用降低安全性，不推荐生产环境)::

   # Allow members of group sudo to execute any command
   #%sudo  ALL=(ALL:ALL) ALL
   %sudo   ALL=(ALL:ALL) NOPASSWD:ALL
   
- ``virsh edit z-ubuntu20`` 修订网络，更改为 :ref:`libvirt_bridged_network`  ``br0`` ，再次重启虚拟机

- Ubuntu Server使用 :ref:`netplan` 管理网络，所以修订 ``/etc/netplan/01-netcfg.yaml`` ::

   network:
     version: 2
     renderer: networkd
     ethernets:
       enp1s0:
         dhcp4: no
         dhcp6: no
         addresses: [192.168.6.246/24, ]
         gateway4: 192.168.6.200
         nameservers:
            addresses: [192.168.6.200, ]

然后执行以下命令生效::

   sudo netplan generate
   sudo netplan apply

- 配置用户帐号 :ref:`ssh` 密钥认证登录

- 结合 :ref:`apt_proxy_arch` 配置虚拟机使用代理服务器更新系统，设置 :ref:`apt` 代理配置 ``/etc/apt/apt.conf.d/proxy.conf`` 添加::

   Acquire::http::Proxy "http://192.168.6.200:3128/";                                                 
   Acquire::https::Proxy "http://192.168.6.200:3128/";

然后更新系统::

   sudo apt update
   sudo apt upgrade

clone虚拟机
=============

- clone基于Ubuntu 20的虚拟机( ``z-b-data-1`` 构建数据存储系统 ``ceph`` / ``etcd`` / ``mysql`` / ``pgsq`` ... )::

   virt-clone --original z-ubuntu20 --name z-b-data-1 --auto-clone 

.. note::

   ``virt-clone`` 命令clone出来的虚拟机会自动修订 ``uuid`` 以及虚拟网卡的 ``mac address`` ，所以不用担心虚拟机冲突

- 对于 :ref:`add_ceph_osds_zdata` 失败的虚拟机，采用如下方法销毁::

   sudo virsh destroy z-b-data-1
   sudo virsh undefine --nvram z-b-data-1 --remove-all-storage

- 然后从模版重新构建虚拟机::

   virt-clone --original z-ubuntu20 --name z-b-data-1 --auto-clone

- 修订虚拟机 :ref:`priv_kvm` ::

   virsh edit z-b-data-1

按照 :ref:`priv_cloud_infra` 修订 :ref:`iommu_cpu_pinning` ::

   <memory unit='KiB'>16777216</memory>
   <currentMemory unit='KiB'>16777216</currentMemory>
   <vcpu placement='static'>4</vcpu>
   <cputune>
     <vcpupin vcpu='0' cpuset='24'/>
     <vcpupin vcpu='1' cpuset='25'/>
     <vcpupin vcpu='2' cpuset='26'/>
     <vcpupin vcpu='3' cpuset='27'/>
   </cputune>

- 启动虚拟机，在虚拟机内部( ``virsh console z-b-data-1`` )执行主机名订正(z-b-data-1)和IP订正(IP从模版的192.168.6.246改成192.168.6.204)，并且调整 :ref:`systemd_timesyncd` 配置::

   hostnamectl set-hostname z-b-data-1
   sed -i 's/192.168.6.246/192.168.6.204/g' /etc/netplan/01-netcfg.yaml
   netplan generate
   netplan apply
   sed -i '/192.168.6.246/d' /etc/hosts
   echo "192.168.6.204    z-b-data-1" >> /etc/hosts
   echo "NTP=192.168.6.200" >> /etc/systemd/timesyncd.conf

添加pass-through NVMe存储
=============================

上述 ``z-b-data-X`` 共有3台虚拟机，通过 :ref:`iommu_cpu_pinning` 关联到物理主机 ``socket 0 CPU`` 。根据 :ref:`hpe_dl360_gen9` 硬件规格， ``socket 0 CPU`` 和 ``slot 0/1`` 两个PCIe 3.0直接联通，可以获得直接访问这两个插槽上NVMe高性能。所以上述 ``cpu pinning`` 可以提高存储访问性能。

现在我们把3个 :ref:`samsung_pm9a1` 分配到上述3个虚拟机，以便构建 :ref:`ceph` 分布式存储以及各种需要直接访问存储的基础服务。

- 参考 :ref:`ovmf` 执行以下命令检查 :ref:`samsung_pm9a1` 存储的ID::

   lspci -nn | grep -i samsung

可以看到::

   05:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   08:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]
   0b:00.0 Non-Volatile memory controller [0108]: Samsung Electronics Co Ltd Device [144d:a80a]

这里第一列的id对应了每个PCIe，也就是我们要指定给虚拟机的标识配置。

- 创建3个PCIe设备配置XML文件分别对应上述设备:

.. literalinclude:: ../../kvm/iommu/ovmf/samsung_pm9a1_1.xml
   :language: xml
   :linenos:
   :caption: Samsung PM9A1 #1

.. literalinclude:: ../../kvm/iommu/ovmf/samsung_pm9a1_2.xml
   :language: xml
   :linenos:
   :caption: Samsung PM9A1 #2

.. literalinclude:: ../../kvm/iommu/ovmf/samsung_pm9a1_3.xml
   :language: xml
   :linenos:
   :caption: Samsung PM9A1 #3

- 执行以下设备添加命令，分别将3个NVMe设备pass-through给3个 ``z-b-data-X`` 虚拟机::

   virsh attach-device z-b-data-1 samsung_pm9a1_1.xml --config
   virsh attach-device z-b-data-2 samsung_pm9a1_2.xml --config
   virsh attach-device z-b-data-3 samsung_pm9a1_3.xml --config

- 启动虚拟机 ``z-b-data-1`` 然后通过控制台访问::

   virsh start z-b-data-1
   virsh console z-b-data-1

- (这里只举例 ``z-b-data-1`` 修订方法)启动基础服务器虚拟机(需要一台台顺序处理，因为需要修订主机名和IP地址)

修改主机名::

   hostnamectl set-hostname z-b-data-1

修订IP地址 - :ref:`netplan` 方式修订 ``/etc/netplan/01-netcfg.yaml`` ::

   IP=192.168.6.204
   sed -i "s/192.168.6.246/$IP/g" /etc/netplan/01-netcfg.yaml

   netplan generate
   netplan apply

   ip addr

修订 ``/etc/hosts`` 添加自身主机IP解析(这步非常重要，如果不能对自身IP解析会导致 :ref:`sudo` 非常缓慢)::

   192.168.6.204  z-b-data-1

- 同样完成 ``z-b-data-2`` 和 ``z-b-data-3`` 的启动和修订

- :ref:`virsh_manage_vm` 设置 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 在操作系统启动时自动启动(这3个虚拟机是 :ref:`priv_cloud_infra` 中关键的数据存储层服务器，所有虚拟机集群的数据存储，所以必须自动启动运行才能提供其他虚拟机运行基础) ::

   for vm in z-b-data-1 z-b-data-2 z-b-data-3;do
     virsh autostart $vm
   done

重建虚拟机 ``z-b-data-1``
===========================

我在部署 :ref:`install_ceph_manual_zdata` 遇到了自定义Ceph集群名部署问题，由于需要尽快完成大量测试实践，所以准备回退到初始环境重新开始 :ref:`install_ceph_manual` 。对于虚拟机环境 ``z-b-data-1`` 进行重建：

- 按照 :ref:`libvirt_lvm_pool` 实践经验，采用如下命令undefine掉 :ref:`ovmf` (使用UEFI)虚拟机，同时删除掉LVM卷::

   sudo virsh shutdown z-b-data-1
   sudo virsh undefine --nvram z-b-data-1 --remove-all-storage

显示信息::

   Domain z-b-data-1 has been undefined
   Volume 'vda'(/dev/vg-libvirt/z-b-data-1) removed.

上述过程会完整清理掉虚拟机以及LVM卷，现在我们可以完整再重新开始新的部署，重复上一段到部署过程:

- 再次clone虚拟机::

   virt-clone --original z-ubuntu20 --name z-b-data-1 --auto-clone

.. note::

   我在实践中发现 Ubuntu 支持安装过程使用代理服务器，所以不需要采用NAT网络，可以直接配置 :ref:`libvirt_bridged_network` 结合 :ref:`apt_proxy_arch` 就可以完成模版主机安装。完成 :ref:`ubuntu_linux` 安装后，主要就是再按照上文调整 vcpu和memory，以及 ``cpupin`` ，然后添加 ``pass-through`` 的NVMe存储就完全恢复初始状态，然后重新开始 :ref:`install_ceph_manual`
