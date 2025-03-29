.. _clone_vm_rbd:

============================
Clone使用Ceph RBD的虚拟机
============================

在 :ref:`ceph_rbd_libvirt` 环境中部署KVM虚拟机并调试运行正常之后，自然就想要类似 :ref:`libvirt_lvm_pool` 一样，通过 ``virsh vol-clone`` 批量复制VM，来构建大规模集群。

不过，尝试::

   virt-clone --original z-ubuntu20-rbd --name z-k8s-m-1 --auto-clone

提示错误::

   ERROR    [Errno 2] No such file or directory: 'rbd://192.168.6.204/libvirt-pool'

这个问题在 `virt-clone can't handle domains with rbd volumes #177 <https://github.com/virt-manager/virt-manager/issues/177>`_ 有说明， ``virt-install`` 查看 ``pool + vol`` 的VM XML，没有认为存储是被管理的，所以不能clone。

解决思路
============

如果只是因为无法处理Ceph RBD存储中的VM镜像文件，我考虑把clone步骤拆分来完成:

- 将模版虚拟机 ``XML`` 配置中有关 Ceph RBD 磁盘部分摘除，然后剩余部分作为模版
- 使用 ``rbd cp libvirt-pool/z-ubuntu20 libvirt-pool/${VM}`` 来独立clone出RBD磁盘文件
- 摘除的Ceph RBD磁盘配置XML单独保存成独立文件，等VM clone完成后再attach上去 ( 参考 :ref:`ovmf` 添加PCIe设备方法 )

实践Clone Ceph RBD虚拟机
===========================

- 备份 ``z-ubuntu20-rbd`` 配置::

   virsh dumpxml z-ubuntu20-rbd > z-ubuntu20-rbd.xml

- 分离出 ``rbd.xml`` 配置:

.. literalinclude:: clone_vm_rbd/rbd.xml
   :language: xml
   :linenos:
   :caption: rbd磁盘设备XML

请注意，这里 ``rbd.xml`` 配置中，我设置了 ``占位符`` ``RBD_DISK`` ，后面每次可以通过修订这个变量来添加不同设备

- 修订 ``z-ubuntu20-rbd`` 虚拟机配置，摘除 ``RBD`` 磁盘部分::

   virsh edit z-ubuntu20-rbd

- 独立clone出新虚拟机磁盘::

   rbd cp libvirt-pool/z-ubuntu20 libvirt-pool/z-k8s-m-1

完成复制后检查::

   sudo rbd ls -p libvirt-pool

可以看到::

   z-k8s-m-1
   z-ubuntu20

- 刷新libvirt存储池 ``images_rbd`` (否则libvirt看不到新创建的RBD磁盘文件) ::

   virsh pool-refresh images_rbd

- 使用 ``virt-clone`` 完成没有磁盘的虚拟机clone::

   virt-clone --original z-ubuntu20-rbd --name z-k8s-m-1 --auto-clone

提示::

   Allocating 'z-k8s-m-1_VARS.fd'                          | 128 kB  00:00:00
   Clone 'z-k8s-m-1' created successfully.

- 然后生成需要添加磁盘的XML::

   VM=z-k8s-m-1
   cat rbd.xml | sed "s/RBD_DISK/$VM/g" > ${VM}-disk.xml

- 将磁盘配置添加到新虚拟机::

   virsh attach-device $VM ${VM}-disk.xml --config

提示::

   Device attached successfully

- 现在我们就可以启动新虚拟机 ``z-k8s-m-1`` ::

   virsh start z-k8s-m-1

- 在虚拟机内部订正主机名 (后续改为采用 :ref:`kvm_libguestfs` 来完成定制) 

排查clone VM启动问题
========================

这里出现一个问题 ``virsh console z-k8s-m-1`` 没有任何输出，观察日志 ``/var/log/libvirt/qemu/z-k8s-m-1.log`` 发现有 :ref:`tainted_host-cpu`

我对比了一下 ``z-ubuntu20-rbd`` 和clone出来的 ``z-k8s-m-1`` ，发现新虚拟机主要增加了 ``guest_agent`` ::

     <channel type='unix'>
       <source mode='bind' path='/var/lib/libvirt/qemu/channel/target/domain-36-z-k8s-m-1/org.qemu.guest_agent.0'/>
       <target type='virtio' name='org.qemu.guest_agent.0' state='disconnected'/>
       <alias name='channel0'/>
       <address type='virtio-serial' controller='0' bus='0' port='1'/>
     </channel>

其他看不出特别

- 改为 ``virsh start z-k8s-m-1 --console`` 直接连接控制台，原来启动时出现报错::

   !!!! X64 Exception Type - 0D(#GP - General Protection)  CPU Apic ID - 00000000 !!!!
   ExceptionData - 0000000000000000
   RIP  - 000000007EAB8BCA, CS  - 0000000000000038, RFLAGS - 0000000000010002
   RAX  - 49C7C83113FA7698, RCX - 0000000000000000, RDX - 000000007FBD3898
   RBX  - 0000000000000020, RSP - 000000007FF9C9B0, RBP - 00000000746E7684
   RSI  - 00000000746E7668, RDI - 000000007FBD3898
   R8   - 8000000000000001, R9  - 000000007FF9CAC0, R10 - 0000000000000000
   R11  - 0000000000001000, R12 - 00000000746E7665, R13 - 0000000000000000
   R14  - 0000000000000000, R15 - 000000007F2B5E18
   DS   - 0000000000000030, ES  - 0000000000000030, FS  - 0000000000000030
   GS   - 0000000000000030, SS  - 0000000000000030
   CR0  - 0000000080010033, CR2 - 0000000000000000, CR3 - 000000007FC01000
   CR4  - 0000000000000668, CR8 - 0000000000000000
   DR0  - 0000000000000000, DR1 - 0000000000000000, DR2 - 0000000000000000
   DR3  - 0000000000000000, DR6 - 00000000FFFF0FF0, DR7 - 0000000000000400
   GDTR - 000000007FBEE698 0000000000000047, LDTR - 0000000000000000
   IDTR - 000000007F2D0018 0000000000000FFF,   TR - 0000000000000000
   FXSAVE_STATE - 000000007FF9C610
   !!!! Find image based on IP(0x7EAB8BCA) /build/edk2-xUnmxG/edk2-0~20191122.bd85bf54/Build/OvmfX64/RELEASE_GCC5/X64/MdeModulePkg/Universal/Variable/RuntimeDxe/VariableRuntimeDxe/DEBUG/VariableRuntimeDxe.dll (ImageBase=000000007EAB1000, EntryPoint=000000007EABD0EC) !!!!

这个报错看起来是 EFI 错误

解决思路:

- 将新clone出来磁盘添加到原先能够正常运行的 ``z-ubuntu20-rbd`` 上(运行在Ceph RBD的 :ref:`ovmf` 虚拟机)
- 手工按照 ``z-ubuntu20-rbd`` 编辑出 ``z-k8s-m-1`` XML，定义虚拟机
- 升级整个Host主机操作系统，再次尝试
- 完全全新使用 Ceph RBD 从头开始安装 :ref:`ubuntu_linux` 20.04.3 LTS操作系统 (这个方法是最干净的)

``z-ubuntu20-rbd`` 添加RBD磁盘启动
-------------------------------------

- 将RBD磁盘 ``z-k8s-m-1-disk.xml`` 内容插入到 ``z-ubuntu20-rbd`` 进行测试: 

.. literalinclude:: clone_vm_rbd/z-k8s-m-1-disk.xml
   :language: xml
   :linenos:
   :caption: z-ubuntu20-rbd 使用 z-k8s-m-1-disk.xml

添加磁盘后启动 ``z-ubuntu20-rbd`` ::

   virsh start z-ubuntu20-rbd --console

输出信息

.. literalinclude:: clone_vm_rbd/z-ubuntu20-rbd_console.txt
   :language: bash
   :linenos:
   :caption: z-ubuntu20-rbd 启动控制台信息

可以看到采用原始 ``z-ubuntu20-rbd`` 配置启动是完全正常的，这说明前述 ``virt-clone`` 出来配置存在不兼容问题::

   virt-clone --original z-ubuntu20-rbd --name z-k8s-m-1 --auto-clone

全新安装基于Ceph RBD虚拟机模版
---------------------------------

我在 :ref:`ceph_rbd_libvirt` 实践中全新安装 ``z-ubuntu20-rbd`` ，安装完成后检查::

   virsh dumpxml z-ubuntu20-rbd > z-ubuntu20-rbd.xml

.. literalinclude:: clone_vm_rbd/z-ubuntu20-rbd.xml
   :language: xml
   :linenos:
   :caption: z-ubuntu20-rbd 全新安装dumpxml

- 对全新安装的基于Ceph RBD的虚拟机进行clone::

   virt-clone --original z-ubuntu20-rbd --name z-k8s-m-1 --auto-clone

依然失败::

   ERROR    [Errno 2] No such file or directory: 'rbd://192.168.6.204:6789/libvirt-pool'

所以，重新尝试先去除RBD磁盘，再尝试clone

- 从新创建的 ``z-ubuntu20-rbd.xml`` 复制出新版本 ``new-rbd.xml`` 

.. literalinclude:: clone_vm_rbd/new-rbd.xml
   :language: xml
   :linenos:
   :caption: 全新创建VM的rbd磁盘设备XML

- 将 ``z-ubuntu20-rbd`` 的磁盘设备detach掉::

   virsh detach-device z-ubuntu20-rbd new-rbd.xml --config

- 现在 ``z-ubuntu20-rbd`` 没有磁盘，我们开始clone::

   virt-clone --original z-ubuntu20-rbd --name z-k8s-m-1 --auto-clone

成功提示::

   Allocating 'z-k8s-m-1_VARS.fd'    | 128 kB  00:00:00
   Clone 'z-k8s-m-1' created successfully.

- clone出来的 ``z-k8s-m-1`` 没有磁盘，先复制出磁盘::

   sudo rbd cp libvirt-pool/z-ubuntu20-rbd libvirt-pool/z-k8s-m-1

- 然后将磁盘添加::

   VM=z-k8s-m-1
   cat new-rbd.xml | sed "s/RBD_DISK/$VM/g" > ${VM}-disk.xml
   virsh attach-device $VM ${VM}-disk.xml --config

- 启动虚拟机::

   virsh start $VM

通过全新安装 :ref:`ceph_rbd_libvirt` 虚拟机进行clone，是可以成功完成虚拟机复制的。之前在 :ref:`libvirt_lvm_pool` 虚拟机的虚拟磁盘导入 :ref:`ceph_rbd` ，我手工修改的原始VM xml配置，虽然首个导入VM可以正常运行，但是再通过 ``virt-clone`` 复制存在不兼容问题。

目前 workaround 方式是每个模版虚拟机在 :ref:`ceph_rbd_libvirt` 重新安装一次，然后作为模版进行clone复制。

- 虚拟机内部需要修订内容有::

   # 主机名
   sudo hostnamectl set-hostname z-k8s-m-1
   # IP
   sudo sed -i 's/192.168.6.247/192.168.6.101/g' /etc/netplan/01-netcfg.yaml
   # hosts
   sudo sed -i '/z-ubuntu-rbd/d' /etc/hosts
   echo "192.168.6.101  z-k8s-m-1.huatai.me  z-k8s-m-1" | sudo tee -a /etc/hosts

libguestfs
==============

为了便于脚本化完成大批虚拟机的创建，我们可以采用 :ref:`kvm_libguestfs` 完成虚拟机镜像修改，这样就无需手工操作。

- 通过 ``guestfish`` 访问 :ref:`ceph_rbd` 磁盘::

   sudo guestfish -i -d z-k8s-m-2

这里 ``-d z-k8s-m-2`` 就是访问 ``libvirt`` 中domain ``z-k8s-m-2`` ，会直接启动一个内核环境挂载虚拟机的磁盘(对于Ceph RBD磁盘也可以处理，说明是通过 ``libvirt`` 实现的)

.. note::

   在 ``guestfish`` 交互命令中 ``><fs>`` 是提示符，所以后续案例中，不要输入 ``><fs>`` 

- 修改虚拟机主机名::

   ><fs> write /etc/hostname "z-k8s-m-2"

在 ``guestfish`` 中，提供了非常微小的 ``busybox`` 系统，但是没有完整的运维工具，所以想使用 ``sed`` 编辑需要一些曲折::

   ><fs> download /etc/netplan/01-netcfg.yaml /tmp/01-netcfg.yaml
   ><fs> ! sed -i 's/192.168.6.247/192.168.6.102/g' /tmp/01-netcfg.yaml 
   ><fs> upload /tmp/01-netcfg.yaml /etc/netplan/01-netcfg.yaml

.. note::

   在 ``guestfish`` 内部没有提供运维工具，如 ``sed`` ，但是可以把文件 ``download`` 到本地物理主机上( 注意，就是运行虚拟机的host物理主机 )，然后通过 ``!`` 就可以运行本地物理主机上工具来处理。

   这里你可以看到我是先把 ``/etc/netplan/01-netcfg.yaml`` 文件下载到物理主机 ``zcloud`` 的 ``/tmp`` 目录下( 也就是物理主机 ``/tmp/01-netcfg.yaml`` )，修改好以后再 ``upload`` 回去

上述交互命令命令可以改写成一段脚本:

.. literalinclude:: clone_vm_rbd/change_vm_ip.sh
   :language: bash
   :linenos:
   :caption: 修改虚拟机IP的简单脚本

完整的clone脚本
=================

- 将上述复制虚拟机以及通过 libguestfs 工具修订虚拟机配置的步骤串联起来，形成一个简单的 ``clone_vm.sh`` 脚本，使用方法如下::

   ./clone_vm.sh z-k8s-m-3

.. literalinclude:: clone_vm_rbd/clone_vm.sh
   :language: bash
   :linenos:
   :caption: clone虚拟机的简单脚本

.. note::

   实际使用时请根据环境做一些修订:

   - 我这里模版虚拟机 ``z-ubuntu20-rbd`` 安装时设置该虚拟机IP地址是 ``192.168.6.247``


参考
========

- `Bug 1392798 - secrets from libvirt domains are not read <https://bugzilla.redhat.com/show_bug.cgi?id=1392798>`_
