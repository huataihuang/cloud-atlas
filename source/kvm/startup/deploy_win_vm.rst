.. _deploy_win_vm:

=============================
部署Windows KVM虚拟机
=============================

在 :ref:`kvm_docker_in_studio` 部署了KVM运行环境之后，就可以 :ref:`create_vm` ，在一台物理服务器上模拟规模化部署的集群。不过，和Linux Guest不同，Windows虚拟机由于闭源以及驱动上的缺陷，运行比较困难，消耗资源也较多。

本文记录部署Windows虚拟机的，以及一些特殊的配制调整。我计划在后续学习和实践性能优化。

创建Windows虚拟机
=====================

- 安装 ``virt-viewer`` 工具可以提供spice或vnc方式连接安装的虚拟机图形界面，程序名称是 ``remote viewer``

对于远程服务器上启动的Windows虚拟机，由于VNC/SPICE只监听本地127.0.0.1:5900端口，所以需要通过ssh端口转发方式访问，即在本地客户端上ssh到远程服务器上::

   ssh -C -L 5900:127.0.0.1:5900 <server_ip>

这样使用本地 ``remote viewer`` 访问 ``spice://127.0.0.1:5900`` 就可以看到Windows桌面，也就能够进行安装了。

- 创建 :ref:`win10` 虚拟机::

   virt-install \
     --network bridge=virbr0,model=virtio \
     --name win10 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=windows --os-variant=win10 \
     --disk path=/var/lib/libvirt/images/win10.qcow2,format=qcow2,bus=virtio,cache=none,size=32 \
     --graphics spice \
     --cdrom=/var/lib/libvirt/images/Win10_1903_V2_English_x64.iso

.. note::

   这里有提示::

     WARNING  Graphics requested but DISPLAY is not set. Not running virt-viewer.
     WARNING  No console to launch for the guest, defaulting to --wait -1

Windows系统没有包涵virtio驱动，所以在系统安装时候必须提供开源社区提供的 `virtio-win/kvm-guest-drivers-windows <https://github.com/virtio-win/kvm-guest-drivers-windows>`_ 提供了最新的release光盘镜像。

.. note::

   实践验证 :ref:`macos` 内置的 vnc  客户端访问安装程序的VNC界面存在问题，我尝试发现目前(2023年) 在 App Store中提供的 ``Remote Ripple`` 非常兼容

- 创建 :ref:`win7` 虚拟机(失败):

.. literalinclude:: deploy_win_vm/win7
   :language: bash
   :caption: 创建 :ref:`win7` 虚拟机，使用 :ref:`ceph_rbd_libvirt` 启动用UEFI(验证失败)

不过，我遇到非常奇怪的问题，Win7启动安装失败，直接进入了 UEFI 操作界面，参考 `Windows 7 single gpu passthrough vm? <https://www.reddit.com/r/VFIO/comments/tweb7x/windows_7_single_gpu_passthrough_vm/>`_ 有一段解释:

这是由于installer并没有为UEFI, NVME 或 USB3 构建，需要将Win 7替换成Win10才能支持。这样才能加载驱动。不过对于Windows 7纯净的UEFI(non-CSM booting)不能共奏，除非能够Flashboot绕过这个我问题

比较简单的方法是暂时放弃UEFI，改为传统的BIOS模式。不过 参考 :ref:`ovmf_gpu_nvme` ，实际上Win7也可以启动用OVMF，待实践(步骤比较复杂)，当前先采用BIOS模式

.. literalinclude:: deploy_win_vm/win7_bios
   :language: bash
   :caption: 创建 :ref:`win7` 虚拟机，使用 :ref:`ceph_rbd_libvirt` 启动用BIOS

.. note::

   :strike:`这里我实际没有重新开始安装，而是修订 virsh edit 虚拟机配置，去除UEFI，然后重新启动进行安装`

   还是遇到一个问题，能够看到从cd-rom启动，但是停滞在 ``Booting from DVD/CD ...`` ，所以删除虚拟机重新开始::

      sudo virsh undefine --nvram z-win7 --remove-all-storage

:strike:`虽然 Win7 安装时不能选择uefi支持` ，但是应该可以在安装以后进行转换。参考 `QEMU/KVM Change Existing Win10 from BIOS to UEFI <https://www.reddit.com/r/VFIO/comments/xusob5/qemukvm_change_existing_win10_from_bios_to_uefi/>`_ ，毕竟微软官方文档说明Win 7是支持UEFI的。后续待实践

在arch linux中，通过AUR可以安装 virtio-win 软件包::

   yay -S virtio-win

.. note::

   对应上游请参考 `Creating Windows virtual machines using virtIO drivers <https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html>`_ ，通过AUR下载的virtio-win驱动位于 ``/usr/share/virtio/`` 目录。

由于 ``virt-install`` 不直接支持多个cdrom，所以在上述安装启动之后，需要将当前cdrom配置导出成一个xml文件，参考第一个cdrom配置修订虚拟机，增加第二个cdrom设备(cdrom 不支持热插拔，所以需要重启虚拟机)，以便在Windows安装过程中提供virtio驱动。(参考 `Using virt-install to mount multiple cdrom drives/images <https://superuser.com/questions/147419/using-virt-install-to-mount-multiple-cdrom-drives-images/677766>`_ )

virt-install会创建一个对应虚拟机的XML配置文件，位于 ``/etc/libvirt/qemu/`` 目录下，以上案例就是 ``/etc/libvirt/qemu/win10.xml`` 。查看该文件可以看到定义的第一个cdrom配置::

    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/en_windows_10_enterprise_version_1607_updated_jul_2016_x86_dvd_9060097.iso'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk> 

执行 ``virsh edit win10`` 修改虚拟机配置，在第一个cdrom之后模仿添加一段，并修改 ``<source file=...>`` ， ``<target dev=...>`` 以及 ``<address unit=...>``::

    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/virtio-win.iso'/>
      <target dev='sdb' bus='sata'/>
      <readonly/>
      <address type='drive' controller='0' bus='0' target='0' unit='1'/>
    </disk> 

由于cdrom/floppy设备不支持热插拔，所以执行 ``virsh edit win10`` 命令修改虚拟机配置，将上述 ``cdrom2.yaml`` 内容复制增加到第一个cdrom下面。

注意，由于默认虚拟机的XML指定启动设备只有硬盘，所以再次使用 ``virsh start win10`` 将不能从光盘启动( 参考 `Booting from a cdrom in a kvm guest using libvirt <https://mycfg.net/articles/booting-from-a-cdrom-in-a-kvm-guest-with-libvirt.html>`_ 。所以，需要在 ``virsh edit win10`` 中将::

     <os>
       <type arch='x86_64' machine='pc-q35-4.1'>hvm</type>
       <boot dev='hd'/>
     </os>

修改成::

     <os>
       <type arch='x86_64' machine='pc-q35-4.1'>hvm</type>
       <boot dev='cdrom'/>
       <boot dev='hd'/>
     </os>

然后启动虚拟机::

   virsh start win10

就可以开始正式安装Windows操作系统了。在安装过程中，最初无法识别的virtio设备，请参考下图添加驱动，注意在提示驱动加载时直接点ok，windows安装程序会自动搜索到可能的驱动，你只需要选择win10驱动就可以了：

.. figure:: ../../_static/kvm/startup/win10_install_load_driver.png
   :scale: 75%   

.. figure:: ../../_static/kvm/startup/win10_install_load_driver_choice.png
   :scale: 75%   

.. figure:: ../../_static/kvm/startup/win10_install_load_driver_install.png
   :scale: 75%   

.. figure:: ../../_static/kvm/startup/win10_install_load_driver_get_disk.png
   :scale: 75%   

安装完毕在重启windows操作系统之前，请务必重新 ``virsh edit win10`` 去除优先从cdrom启动设置。

安装完操Windows之后，需要注意这个虚拟机的硬件，包括虚拟网卡，虚拟串口等设备都是virtio类型的，默认的Windows系统都没有驱动，所以还需要在Windows中使用鼠标右击启动按钮，选择 ``Computer Management`` ，然后选择 ``Device Manager`` ，再选择驱动没有正确安装的设备，例如 ``Ethernet Controller`` 。鼠标右击没有正确安装驱动的设备图标，选择 ``Update Driver Softwre`` 

.. figure:: ../../_static/kvm/startup/win10_update_driver.png
   :scale: 75%   

然后选择 ``Browser my computer for driver software``

.. figure:: ../../_static/kvm/startup/win10_update_driver_locate.png
   :scale: 75%   

点击 ``Browse...`` 浏览选择包含virtio驱动的cdrom，并确认。注意，这里搜索驱动的选项选择了 ``Include subfolers`` 这样才能搜索整个cdrom，找到cdrom子目录中正确的驱动

.. figure:: ../../_static/kvm/startup/win10_update_driver_locate_cdrom.png
   :scale: 75%   

Windows会搜索到正确的驱动，请点击确认安装，注意选择了 ``Always trust software form "Red Hat, Inc"``

.. figure:: ../../_static/kvm/startup/win10_update_driver_install.png
   :scale: 75%   

安装成功

.. figure:: ../../_static/kvm/startup/win10_update_driver_install_success.png
   :scale: 75%   

建议启用windows远程桌面，然后安装 xrdp 客户端，方便从Linux上访问Windows桌面。

.. note::

   Linux也可以安装RDP服务，这样就非常容易从Windows客户端访问Linux桌面。请参考 `Install XRDP on Ubuntu Server with XFCE Template <https://www.interserver.net/tips/kb/install-xrdp-ubuntu-server-xfce-template/>`_

.. note::

   `rdesktop <https://www.rdesktop.org/>`_ 是轻量级RDP客户端，支持SeamlessRDP。

   `Remmina <https://remmina.org/>`_ 是支持多种协议(RDP, VNC, SPICE, NX, XDMCP, SSH and EXEC)的远程桌面客户端。

.. note::

   Windows的更新升级默认会在系统中保留历次update的安装包，以便能够回滚。但是虚拟机磁盘空间往往有限，所以建议通过Disk cleanup工具清理。请参考 `Huge LCU-Folder after latest Cumulative Update on Windows 10 1809 <https://social.technet.microsoft.com/Forums/en-US/be35a9ee-a610-4fdc-bb6c-50b9f458d19a/huge-lcufolder-after-latest-cumulative-update-on-windows-10-1809?forum=win10itprosetup>`_ : ``c:\Windows\servicing\LCU`` 目录即最新累积更新(Lastest Cumulative Update,LCU)中有最近更新的下载软件包，可以通过选择Disk Cleanup工具的 ``Clean up system files`` 然后勾选 ``windows update cleanup`` 清理。

   如果通过第三方软件包安装管理工具安装软件，则可能在 ``c:\Users\<用户名>\AppData\Local\Temp\`` 目录下有缓存下载文件。

关闭Windows虚拟机memballoon
==============================

在实践中发现，Windows虚拟机内部CPU非常容易飙升到100%，即使做简单的Windows升级或者打开Windows虚拟机中浏览器(仅仅查看一个网页)，也会导致物理主机所有CPU都出现极高的SYS使用率。然后出现物理主机Load远超CPU核数，系统相应缓慢hang死。

最初我以为是我启用了 :ref:`btrfs_in_studio` 的 ``zstd`` 压缩导致的虚拟机运行问题（具体实践见 :ref:`using_btrfs_in_studio` )，但是，我切换到 :ref:`lvm_xfs_in_studio` 依然不断发生hang机异常。

实际上，我在部署 :ref:`priv_kvm` 也是采用了完全相同的部署方式，除了虚拟机全部是Linux外，配制方法没有任何区别。但是，我想到之前工作经验，生产环境并没有启用Balloon功能，应该是有一定原因的。由于memballon需要Guest虚拟机内部驱动配合，所以我怀疑Windows Guest virtio memballoon驱动可能存在缺陷。

.. note::

   实际上libvirt配制了 ``memballoon`` 设备，并没有实际运行内存压缩，

   详细请俺靠 :ref:`memballoon` 的实践。

由于 ``memballoon`` 设备无法通过 ``virt edti <dom>`` 删除，我验证过，即使编辑删除xml中的以下配制，保存以后再检查，这段设备配制依然存在::

   <memballoon model='virtio'>
     <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
   </memballoon>

只能通过明确禁用 ( ``model='none'`` ) 配制来关闭 ``memballoon`` 设备，即编辑修改::

   <memballoon model='none'>
     <address type='pci' domain='0x0000' bus='0x05' slot='0x00' function='0x0'/>
   </memballoon>

保存xml配制以后再次检查就会看到如下::

     <devices>
     ...
      <memballoon model='none'/>
     </devices>

关闭balloon之后，重启Windows虚拟机的负载降低。

.. note::

   默认的KVM Windows虚拟机对系统依然比较大，即使关闭了 ``memballoon`` 之后，空载的虚拟机，依然会消耗一个CPU核心的50%处理能力，感觉不是很理想。有待后续进一步优化。
