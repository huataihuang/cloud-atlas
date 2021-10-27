.. _libvirt_lvm_pool:

===========================
libvirt LVM卷管理存储池
===========================

我在构建 :ref:`priv_kvm` 模拟集群时，底层物理主机采用 :ref:`libvirt_storage_arch` 中的两种存储卷:

- LVM存储卷
- 磁盘存储卷

其中LVM存储卷是本文记录的实践，用于 :ref:`priv_cloud_infra` 中第一层KVM虚拟化的虚拟机存储

创建LVM存储卷
================

- 检查当前存储卷::

   virsh pool-list --all

显示目前有2个存储卷::

    Name           State    Autostart
   ------------------------------------
    boot-scratch   active   yes
    images         active   yes

- 手工创建LVM逻辑卷的PV和VG (虽然也可以使用 virsh 创建) ::

   parted -a optimal /dev/sda mkpart primary 235GB 100%
   parted /dev/sda set 4 lvm on
   parted /dev/sda name 4 libvirt

.. note::

   这里是对 ``/dev/sda`` 剩余的磁盘空间划分一个 ``sda4`` 作为LVM

创建卷管理::

   pvcreate /dev/sda4
   vgcreate vg-libvirt /dev/sda4

检查VG::

   vgs

显示输出::

   VG         #PV #LV #SN Attr   VSize    VFree
   vg-libvirt   1   0   0 wz--n- <258.08g <258.08g

- 使用 ``virsh`` 创建逻辑卷存储卷::

   virsh pool-define-as images_lvm logical --source-name vg-libvirt --target /dev/sda4

- 启动存储卷::

   virsh pool-start images_lvm
   virsh pool-autostart images_lvm

- 创建卷(用于虚拟机)::

   virsh vol-create-as images_lvm centos6 12G

然后可以检查LVM卷::

   lvdisplay

可以看到::

   --- Logical volume ---
   LV Path                /dev/vg-libvirt/centos6
   LV Name                centos6
   VG Name                vg-libvirt
   LV UUID                icj4Kd-ZNwh-DAYj-mQBr-1daJ-WRmG-fAr2UD
   LV Write Access        read/write
   LV Creation host, time zcloud, 2021-10-25 23:48:11 +0800
   LV Status              available
   # open                 0
   LV Size                12.00 GiB
   Current LE             3072
   Segments               1
   Allocation             inherit
   Read ahead sectors     auto
   - currently set to     256
   Block device           253:0

- 也可以使用 ``virsh`` 命令显示可用卷::

   virsh vol-list images_lvm

显示::

    Name      Path
   ------------------------------------
    centos6   /dev/vg-libvirt/centos6

使用LVM卷命令检查::

   lvscan

显示::

     ACTIVE            '/dev/vg-libvirt/centos6' [12.00 GiB] inherit

::

   lvs

显示::

   LV      VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   centos6 vg-libvirt -wi-a----- 12.00g

创建虚拟机
==============

CentOS 6
-------------

- 创建CentOS 6.10模版虚拟机::

   virt-install \
     --network bridge:virbr0 \
     --name centos6 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=centos6.0 \
     --disk path=/dev/vg-libvirt/centos6,sparse=false,format=raw,bus=virtio,cache=none,io=native \
     --graphics none \
     --location=http://mirrors.163.com/centos-vault/6.10/os/x86_64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

- 虚拟机文件系统配置:

  - 使用XFS
  
    - 文件系统scheduler设置为 deadline
  
  - 虚拟机内部直接使用文件系统，不使用复杂的LVM卷，以便能够避免LVM堆砌，尽可能提高性能

.. note::

   RHEL/CentOS 6还没有对XFS完善支持，所以采用EXT4文件系统，不过在CentOS7开始可以采用XFS

- 安装完成后检查 ``virsh edit centos6`` 可以看到磁盘配置::

   <disk type='block' device='disk'>
     <driver name='qemu' type='raw' cache='none' io='native'/>
     <source dev='/dev/vg-libvirt/centos6'/>
     <target dev='vda' bus='virtio'/>
     <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
   </disk>

CentOS 7
----------

- LVM磁盘::

   virsh vol-create-as images_lvm centos7 6G

- 创建CentOS 7 模版虚拟机::

   virt-install \
     --network bridge:virbr0 \
     --name centos7-lvm \
     --ram=2048 \
     --vcpus=1 \
     --os-type=centos7.0 \
     --disk path=/dev/vg-libvirt/centos7,sparse=false,format=raw,bus=virtio,cache=none,io=native \
     --graphics none \
     --location=http://mirrors.163.com/centos/7/os/x86_64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

- 由于终端控制台安装无法对磁盘进行定制，所以安装过程中选择启动vnc，此时提示::

   03:52:24 Please manually connect your vnc client to 192.168.122.212:1 to begin the install.
   03:52:24 Attempting to start vncconfig

- 通过ssh端口转发方式访问来，即在本地ssh登陆到zcloud上同时转发本地端口::

   ssh -L 127.0.0.1:5901:192.168.122.212:5901 192.168.6.200

然后本地使用VNC客户端访问 ``127.0.0.1:5901`` 就可以看到安装图形界

.. note::

   注意，这里虚拟安装使用的是传统的BIOS模式，所以无法实现 :ref:`iommu` pass-through PCIe 设备(以及 ``--cpu host-passthrough`` )到虚拟机内部。要实现 :ref:`intel_vt-d_startup` 这样的 :ref:`vfio` 以及进一步的 :ref:`sr-iov` ，需要使用 :ref:`ovmf` 技术

clone虚拟机
============

- 使用 ``virsh vol-clone`` 进行clone::

   virsh vol-clone centos6 kernel-dev --pool images_lvm


参考
=====

- `CREATING AN LVM-BASED STORAGE POOL WITH VIRSH <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_administration_guide/create-lvm-storage-pool-virsh>`_
- `Create an LVM Storage Pool with Libvirt <https://acloudguru.com/hands-on-labs/create-an-lvm-storage-pool-with-libvirt>`_
- `Virsh vol-clone <https://kb.novaordis.com/index.php/Virsh_vol-clone>`_
- `How to clone existing KVM virtual machine images on Linux <https://www.cyberciti.biz/faq/how-to-clone-existing-kvm-virtual-machine-images-on-linux/>`_
