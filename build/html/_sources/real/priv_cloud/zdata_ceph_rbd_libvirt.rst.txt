.. _zdata_ceph_rbd_libvirt:

==================================
私有云基于 ZData Ceph 运行虚拟机
==================================

在我的 :ref:`priv_cloud_infra` ，是一个基于KVM虚拟化的模拟大规模集群，所以，在 :ref:`zdata_ceph` 部署作为整个虚拟化底层Ceph存储，用于第一层KVM虚拟机的镜像存储。完成存储部署之后，现在到了如何把 ``zcloud`` 上运行的KVM虚拟机存储结合到Ceph分布式存储的阶段。

为了方便虚拟化部署，我们通常会采用 :ref:`libvirt` 来管理VM以及相关的存储和网络，对于 :ref:`ceph` 也不例外。通过 :ref:`ceph_rbd_libvirt` ，可以让QEMU通过 ``librbd`` 来访问Ceph OSD提供的块存储。

部署方案
==========

- :ref:`ceph_rbd_libvirt` 提供KVM虚拟机管理 :ref:`zdata_ceph`
- 基于 :ref:`ceph_rbd` 存储部署 :ref:`ubuntu_linux`
- :ref:`clone_vm_rbd` 复制出满足部署 :ref:`kubernetes` 和 :ref:`openstack` 集群的第一层虚拟机
- 采用 :ref:`kvm_libguestfs` 对clone后的VM镜像进行定制，正确配置主机名、IP以及必要配置

既然我已经完成了 :ref:`zdata_ceph` ，现在就来配置 ``libvirt`` 运行基于Ceph的虚拟机：

配置Ceph
==========

- 创建存储池::

   sudo ceph osd pool create libvirt-pool

创建成功则提示::

   pool 'libvirt-pool' created

- 检查这个创建资源池的pg数量::

   sudo ceph osd pool get libvirt-pool pg_num

显示::

   pg_num: 81

上述 ``osd pool`` 是管理Ceph资源的逻辑概念，将对应于 ``libvirt`` 的存储池

- 使用 ``rbd`` 工具初始化资源池用于RBD::

   sudo rbd pool init libvirt-pool

- 创建一个Ceph用户::

   sudo ceph auth get-or-create client.libvirt mon 'profile rbd' osd 'profile rbd pool=libvirt-pool'

客户端(使用Ceph)
===================

- 在运行 :ref:`kvm` 和 :ref:`libvirt` 的虚拟化服务器上，需要安装 ``ceph-common`` 软件包::

   sudo apt install ceph-common

配置libvirt RBD存储池
------------------------

- ``libvirt`` 需要定义RBD存储池，需要首先配置访问Ceph存储的secret::

   SECRET_UUID=$(uuidgen)
   cat >secret.xml <<__XML__
   <secret ephemeral='no' private='no'>
     <uuid>$SECRET_UUID</uuid>
     <usage type='ceph'>
       <name>client.libvirt secret</name>
     </usage>
   </secret>
   __XML__

   virsh secret-define --file secret.xml
   virsh secret-set-value --secret "$SECRET_UUID" --base64 "$(sudo ceph auth get-key client.libvirt)"

- 设置 ``libvirt-pool`` 存储池::

   cat >pool.xml <<__XML__
   <pool type="rbd">
     <name>images_rbd</name>
     <source>
       <name>libvirt-pool</name>
       <host name='192.168.6.204'/> # ceph monitor 1
       <host name='192.168.6.205'/> # ceph monitor 2
       <host name='192.168.6.206'/> # ceph monitor 3
       <auth username='libvirt' type='ceph'>
         <secret uuid='$SECRET_UUID'/>
       </auth>
     </source>
   </pool>
   __XML__

   virsh pool-define pool.xml
   virsh pool-start images_rbd
   virsh pool-autostart images_rbd

- 然后验证检查::

   virsh vol-list images_rbd

创建虚拟机
---------------

.. note::

   目前我的实践发现，之前在 :ref:`libvirt_lvm_pool` 构建的VM，虽然能够通过 ``qemu-img`` 转换到到RBD中镜像文件，但是手工配置的VM的XML配置，在 :ref:`clone_vm_rbd` 尝试clone虚拟机无法启动。所以，最后我还是采用全新基于Ceph存储的VM操作系统安装，才完成clone。

- 创建RBD磁盘::

   virsh vol-create-as --pool images_rbd --name z-ubuntu20-rbd --capacity 7GB --allocation 7GB --format raw

- 安装虚拟机::

   virt-install \
     --network bridge:br0 \
     --name z-ubuntu20-rbd \
     --ram=2048 \
     --vcpus=1 \
     --os-type=Linux --os-variant=ubuntu20.04 \
     --boot uefi --cpu host-passthrough \
     --disk vol=images_rbd/z-ubuntu20-rbd,sparse=false,format=raw,bus=virtio,cache=none,io=native \
     --graphics none \
     --location=http://mirrors.163.com/ubuntu/dists/focal/main/installer-amd64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

安装完成后按照 :ref:`priv_kvm` 中订正虚拟机配置(登陆到虚拟机内部执行):

- 修订NTP::

   echo "NTP=192.168.6.200" >> /etc/systemd/timesyncd.conf

- 修订控制台输出

默认安装 ``/etc/default/grub`` 内容::

   GRUB_TERMINAL=serial
   GRUB_SERIAL_COMMAND="serial --unit=0 --speed=115200 --stop=1"

修改成::

   GRUB_CMDLINE_LINUX="console=ttyS0,115200"
   GRUB_TERMINAL="serial console"
   GRUB_SERIAL_COMMAND="serial --speed=115200"

然后执行::

   sudo update-grub

- 修订虚拟机 ``/etc/sudoers`` 并添加主机登陆ssh key

clone虚拟机
----------------

在完成了第一个虚拟机 ``z-ubuntu20-rbd`` 创建之后，后续的虚拟机都采用这个模版进行clone。我在实践中发现，类似之前 :ref:`libvirt_lvm_pool` 直接采用 ``virt-clone`` 命令会遇到无法管理 RBD 存储池的问题。所以采用 :ref:`clone_vm_rbd` 中探索的变通方法:

- 将模版虚拟机 ``XML`` 配置中有关 Ceph RBD 磁盘部分摘除，然后剩余部分作为模版
- 使用 ``rbd cp libvirt-pool/z-ubuntu20 libvirt-pool/${VM}`` 来独立clone出RBD磁盘文件
- 摘除的Ceph RBD磁盘配置XML单独保存成独立文件，等VM clone完成后再attach

为了方便处理，编写一个简单的脚本 ``change_vm.sh`` 完成这个操作步骤:

.. literalinclude:: ../../ceph/rbd/clone_vm_rbd/clone_vm.sh
   :language: bash
   :linenos:
   :caption: clone虚拟机的简单脚本

- 脚本中结合了 :ref:`kvm_libguestfs` 工具来定制clone出来的虚拟机配置，所以可以直接完成虚拟机clone和启动，无需手工登陆虚拟机内部修改配置。

执行clone命令( 举例 ``z-k8s-m-3`` )::

   ./clone_vm.sh z-k8s-m-3

通过上述方法按照 :ref:`priv_cloud_infra` 规划的虚拟机列表，完成虚拟机创建。
