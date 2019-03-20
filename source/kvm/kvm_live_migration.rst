.. _kvm_live_migration:

====================
KVM热迁移
====================

准备工作
=============

KVM虚拟化技术有一个非常有用的杀手锏技术 :ref:`kvm_live_migration` ，我们现在已经得到了支持嵌套虚拟化的虚拟机 ``devstack`` ，我们现在从这个 ``devstack`` 复制出我们热迁移用的两个虚拟机 ``devstack-1`` 和 ``devstack-2`` ::

   virt-clone --connect qemu:///system --original devstack --name devstack-1 --file /var/lib/libvirt/images/devstack-1.qcow2
   sudo virt-sysprep -d devstack-1 --hostname devstack-1 --root-password password:CHANGE_ME

   virt-clone --connect qemu:///system --original devstack --name devstack-2 --file /var/lib/libvirt/images/devstack-2.qcow2
   sudo virt-sysprep -d devstack-2 --hostname devstack-2 --root-password password:CHANGE_ME

这两个支持 Nested Virtualization 的虚拟机 ``devstack-1`` 和 ``devstack-2`` 不仅是我们测试嵌套虚拟化的虚拟机，也是测试 热迁移技术的虚拟机。我们这里使用 :ref:`kubernetes` 中 :ref:`install-run-minikube` 来作为"嵌在内部"的虚拟机。

.. note::

   ``minikube`` 虚拟机是2c2g配置，我们需要调整 ``devstack-1`` 和 ``devstack-2`` 的虚拟机配置，修订成 ``2c4g`` 配置来支持嵌套运行 ``minikube``

- 在 ``devstack-1`` 和 ``devstack-2`` 虚拟机的内部参考 :ref:`kvm_docker_in_studio` 安装KVM运行环境::

   sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libguestfs-tools

基于NFS共享存储
===========================

KVM热迁移实现需要使用共享的存储池，最简便的方法是使用NFS共享。更为复杂且高可用、高性能的是使用共享的分布式文件系统，如Ceph ( 请参考 :ref:`ceph` )。

- 在 ``xcloud`` 物理主机上 :ref:`btrfs_in_studio` 创建子卷 ``images`` ::

   btrfs subvolume create /data/images

- 修改 ``/etc/fstab`` 添加::

   /dev/sda3    /nfs/images        btrfs  subvol=images,defaults,noatime    0   1

- 挂载目录::

   mkdir -p /nfs/images
   mount /nfs/images

- 安装NFS服务::

   apt install nfs-kernel-server

- 设置NFS共享，即编辑 ``/etc/exports`` ::

   /nfs/images    192.168.122.0/24(rw,sync,no_root_squash,no_subtree_check)

- 服务器端输出NFS::

   exportfs -a

NFS客户端挂载
------------------

在作为KVM虚拟化运行的主机 ``devstack-1`` 和 ``devstack-2`` 中使用NFS方式挂载 ``xcloud`` 共享出来的NFS存储，以下命令都在这两个虚拟机中运行:

- 安装NFS客户端::

   apt install nfs-common

- 编辑 ``/etc/fstab`` 添加::

   192.168.122.1:/nfs/images  /var/lib/libvirt/nfs-images  nfs  auto,rw,vers=3,hard,intr,tcp,rsize=32768,wsize=32768      0   0

- 客户端挂载::

   mkdir /var/lib/libvirt/images
   mount /var/lib/libvirt/images

挂载之后，在 ``devstack-1`` 和 ``devstack-2`` 两个虚拟机内部都会看到共享存储如下::

   192.168.122.1:/nfs/images  184G   13G  170G   8% /var/lib/libvirt/images

配置libvirt的VM存储池
============================

默认情况下libvirt使用的存储池目录是 ``/var/lib/libvirt/images`` ，需要修改成热迁移共享存储NFS。

.. note::

   必须检查 ``devstack-1`` 和 ``devstack-2`` 上所有虚拟机运行状态，确保所有虚拟机都已经关闭::

      virsh list --all

- 检查存储池::

   virsh pool-list --all

如果没有创建过虚拟机，上述存储池输出可能是空的。如果创建了虚拟机，默认会有一个 ``images`` 存储池。这里尝试创建一个虚拟机来激活存储池::

   virt-install \
     --network bridge:virbr0 \
     --name ubuntu18.04 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=ubuntu18.04 \
     --disk path=/var/lib/libvirt/images/ubuntu18.04.qcow2,format=qcow2,bus=virtio,cache=none,size=16 \
     --graphics none \
     --location=http://mirrors.163.com/ubuntu/dists/bionic/main/installer-amd64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

报错::

   ERROR    Couldn't create storage volume 'ubuntu18.04.qcow2': 'internal error: Child process (/usr/bin/qemu-img create -f qcow2 -o preallocation=metadata,compat=1.1,lazy_refcounts /var/lib/libvirt/images/ubuntu18.04.qcow2 16777216K) unexpected exit status 1: qemu-img: /var/lib/libvirt/images/ubuntu18.04.qcow2: Failed to lock byte 100

.. note::

  参考 `Bug 1547095 - QEMU image locking on NFSv3 prevents VMs from getting restarted on different hosts upon an host crash, seen on RHEL 7.5  <https://bugzilla.redhat.com/show_bug.cgi?id=1547095>`_

   FYI, I'm told by a storage maintainer that this is only really a problem with NFSv3. With NFSv4, locks use an active lease mechanism with the client having to refresh the lease periodically for it to remain valid.  So if you are using NFSv4 and the client dies with locks held, they should be revoked by the server after the lease renewal timeout is reached, allowing another host to acquire them.

   Some more info here about NFSv4 locking here:

   https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.idan400/lockv4.htm

   Given NFSv3 is a legacy protocol, I don't think it justifies disabling locking from QEMU side. The nolock mount option seems like a reasonable  workaround for V3, if the sites in question really can't use V4.

修改NFS挂载::

   192.168.122.1:/nfs/images  /var/lib/libvirt/images  nfs4  _netdev,auto 0 0

然后重新挂载::

   umount /var/lib/libvirt/images
   mount /var/lib/libvirt/images

再次尝试创建虚拟机就可以成功，也就具备了 ``images`` 这个默认存储池。

如果已经有一个 ``images`` 存储池，则使用 ``virsh pool-edit images`` 编辑配置，其中的存储路径修改成新的NFS共享存储路径 ``/var/lib/libvirt/nfs-images`` 。

- 如果还没有存储池，则创建一个 ``images.xml`` ::

   <pool type="dir">
       <name>images</name>
       <target>
             <path>/var/lib/libvirt/images</path>
       </target>
   </pool>

然后执行::

   virsh pool-create nfs-images.xml

.. note::

   以上通过XML文件创建存储池方法也可用命令行实现::

      virsh pool-create-as --name images --type dir --target /var/lib/libvirt/images

   当然也可以直接创建一个虚拟机来实现存储卷 ``images``

.. note::

   详细请参考 `Storage Pool Commands <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-managing_guest_virtual_machines_with_virsh-storage_pool_commands>`_

测试虚拟机
=====================

在 :ref:`create_vm_in_studio` 创建过第一个虚拟机名为 `ubuntu18.04` ，我们现在将这个虚拟机从 ``xcloud`` 物理服务器上复制到支持嵌套虚拟化的 ``devstack-1`` 虚拟机中，存放到 ``/var/lib/libvirt/images`` 目录下::

- 在 ``xcloud`` 上执行::

   cd /var/lib/libvirt/images
   scp ubuntu18.04.qcow2 devstack-1:/var/lib/libvirt/images/nested-ubuntu18.04.qcow2

.. note::

   由于 ``devstack-1`` 的NFS共享挂载的就是 ``xcloud`` 的 ``/nfs/images`` 目录，所以上述命令其实也可以在 ``xcloud`` 上直接复制到本地目录 ``/nfs/images`` 下，同样会被 ``devstack-1`` 和 ``devstack-2`` 使用::

      cp ubuntu18.04.qcow2 /nfs/images/nested-ubuntu18.04.qcow2

- 在 ``devstack-1`` 和 ``devstack-2`` 中检查 ``/var/lib/libvirt/images`` 目录下应该有如下文件::

    -rw------- 1 root root 17G Mar 13 16:56 nested-ubuntu18.04.qcow2

修改成 ``libvirt-qemu:kvm`` 属主::

    chown libvirt-qemu:kvm /var/lib/libvirt/images/nested-ubuntu18.04.qcow2

- 在 ``devstack-1`` 上导入这个虚拟机 (使用 ``--import`` 参数 )::

   virt-install \
     --network bridge:virbr0 \
     --name nested-ubuntu18.04 \
     --os-type=ubuntu18.04 \
     --ram=2048 \
     --vcpus=1 \
     --disk path=/var/lib/libvirt/images/nested-ubuntu18.04.qcow2,format=qcow2,bus=virtio,cache=none \
     --network bridge=virbr0,model=virtio \
     --import 

.. note::

   这里还有一点问题，照例说使用了 ``--import`` 不应该出现安装过程。不过依然可以使用

热迁移
==================

- 在 ``devstack-1`` 和 ``devstack-2`` 主机间设置好ssh免密码登陆

以下命令在物理主机 ``xcloud`` 上执行，将密钥分发到两个测试虚拟机上::

   scp id_rsa* devstack-1:/home/huatai/.ssh/
   scp id_rsa* devstack-2:/home/huatai/.ssh/

- 在 ``devstack-1`` 和 ``devstack-2`` 的 ``/etc/hosts`` 中添加主机名解析::

   192.168.122.21   devstack-1
   192.168.122.22   devstack-2

- 在 ``devstack-1`` 和 ``devstack-2`` 的 ``~/.ssh/config`` 中添加::

   Host *
       ServerAliveInterval 60
       ControlMaster auto
       ControlPath ~/.ssh/%h-%p-%r
       ControlPersist yes

这样只需要一次ssh登陆，后续复用socks就不需要密码::

   ssh devstack-2 "virsh list"

- 热迁移::

   virsh migrate nested-ubuntu18.04 qemu+ssh://devstack-2/system

   virsh migrate nested-ubuntu18.04 qemu+ssh://devstack-1/system
