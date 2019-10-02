.. _create_vm:

=============================
Studio环境创建KVM虚拟机
=============================

.. note::

   在Studio环境中，KVM虚拟化是实现模拟数据中心的核心。因为单纯的Docker+Kubernetes无法模拟多台物理服务器，虽然容器技术更为轻量级。

   为Studio选择的默认Guest操作系统是Ubuntu 18.04，这样可以获得Kernel 4.15，并且得到LTS长期支持。这个基础Guest系统将用于构建OpenStack。

   Studio环境采用Ubuntu作为host和guest的OS，在 :ref:`real` 中， :ref:`priv_kvm` 则采用CentOS作为OS。

创建CentOS虚拟机
------------------

- 创建虚拟机安装Guest操作系统::

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

.. note::

   - ``--graphics none`` 表示不使用VNC来访问VM的控制台，而是使用VM串口的字符控制台。
   - ```--location`` 指定通过网络安装，如果使用本地iso安装，则使用 ``--cdrom /var/lib/libvirt/images/ubuntu-18.04.2-live-server-amd64.iso``
   - 只有通过网络安装才可以使用 ``--extra-args="console=tty0 console=ttyS0,115200"`` 以便能够通过串口控制台安装
   - 要模拟UEFI，需要安装 ``ovmf`` 软件包，并使用参数 ``--boot uefi``
   - root分区采用EXT4文件系统，占据整个磁盘
   - 软件包只选择 ``OpenSSH server`` 以便保持最小化安装，后续clone出的镜像再按需安装

   上述安装是通过 ``virsh console`` 连接到虚拟机的串口控制台实现的，安装完成后，需要 ``detach`` 断开串口控制台: ``CTRL+Shift+]`` ，这就可以返回host主机的控制台。

创建Windows虚拟机
----------------------

- 安装 ``virt-viewer`` 工具可以提供spice或vnc方式连接安装的虚拟机图形界面，程序名称是 ``remote viewer``

- 创建Windows虚拟机::

   virt-install \
     --network bridge=virbr0,model=virtio \
     --name win10 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=windows --os-variant=win10 \
     --disk path=/var/lib/libvirt/images/win10.qcow2,format=qcow2,bus=virtio,cache=none,size=32 \
     --graphics spice \
     --cdrom=/var/lib/libvirt/images/en_windows_10_enterprise_version_1607_updated_jul_2016_x86_dvd_9060097.iso 

.. note::

   这里有提示::

     WARNING  Graphics requested but DISPLAY is not set. Not running virt-viewer.
     WARNING  No console to launch for the guest, defaulting to --wait -1

Windows系统没有包涵virtio驱动，所以在系统安装时候必须提供开源社区提供的 `virtio-win/kvm-guest-drivers-windows <https://github.com/virtio-win/kvm-guest-drivers-windows>`_ 提供了最新的release光盘镜像。

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

.. figure:: ../_static/kvm/win10_install_load_driver.png
   :scale: 75%   

.. figure:: ../_static/kvm/win10_install_load_driver_choice.png
   :scale: 75%   

.. figure:: ../_static/kvm/win10_install_load_driver_install.png
   :scale: 75%   

.. figure:: ../_static/kvm/win10_install_load_driver_get_disk.png
   :scale: 75%   

安装完毕在重启windows操作系统之前，请务必重新 ``virsh edit win10`` 去除优先从cdrom启动设置。

安装完操Windows之后，需要注意这个虚拟机的硬件，包括虚拟网卡，虚拟串口等设备都是virtio类型的，默认的Windows系统都没有驱动，所以还需要在Windows中使用鼠标右击启动按钮，选择 ``Computer Management`` ，然后选择 ``Device Manager`` ，再选择驱动没有正确安装的设备，例如 ``Ethernet Controller`` 。鼠标右击没有正确安装驱动的设备图标，选择 ``Update Driver Softwre`` 

.. figure:: ../_static/kvm/win10_update_driver.png
   :scale: 75%   

然后选择 ``Browser my computer for driver software``

.. figure:: ../_static/kvm/win10_update_driver_locate.png
   :scale: 75%   

点击 ``Browse...`` 浏览选择包含virtio驱动的cdrom，并确认。注意，这里搜索驱动的选项选择了 ``Include subfolers`` 这样才能搜索整个cdrom，找到cdrom子目录中正确的驱动

.. figure:: ../_static/kvm/win10_update_driver_locate_cdrom.png
   :scale: 75%   

Windows会搜索到正确的驱动，请点击确认安装，注意选择了 ``Always trust software form "Red Hat, Inc"``

.. figure:: ../_static/kvm/win10_update_driver_install.png
   :scale: 75%   

安装成功

.. figure:: ../_static/kvm/win10_update_driver_install_success.png
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

虚拟机串口设置
=================

- 设置虚拟机串口输出

通过ssh登陆到刚才创建的虚拟机，然后执行::

   systemctl enable serial-getty@ttyS0.service
   systemctl start serial-getty@ttyS0.service

.. note::

   默认安装的虚拟机并没有提供串口输出，也就是无法通过 ``virsh console ubuntu18.04`` 来访问虚拟机控制台。这样唯一登陆虚拟机的方法是依赖上述最小化安装时候附加安装的 ``OpenSSH server`` 通过网络登陆。注意，此时虚拟机的IP地址是通过 libvirt 的DHCP分配的，所以无法直接知道IP地址。

   可以通过 ``sudo ping -b 192.168.122.255`` 此时在 ``virbr0`` 虚拟网络中广播地址，就可以再通过 ``arp -a | grep virbr0`` 找到运行中虚拟机的IP地址::

      ? (192.168.122.186) at 52:54:00:8a:45:89 [ether] on virbr0

   此时就可以 ``ssh 192.168.122.186`` 登陆到虚拟机内部，再调整虚拟机内核配置输出串口。

.. note::

   Host主机 ``/var/lib/libvirt/dnsmasq/virbr0.status`` 提供了当前dnsmasq分配的IP地址情况。所以上述通过arp解析方法只适合在少数虚拟机时候使用，直接检查这个状态文件可以看到类似::

      [
        {
          "ip-address": "192.168.122.186",
          "mac-address": "52:54:00:8a:45:89",
          "hostname": "ubuntu18-04",
          "client-id": "ff:32:39:f9:b5:00:02:00:00:ab:11:1a:49:39:51:4b:f1:45:b4",
          "expiry-time": 1551337558
        }
      ]
   
.. note::

   详细的KVM虚拟机串口设置请参考 `虚拟机串口控制台 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/libvirt/devices/vm_serial_console.md>`_

虚拟机内部初始设置
=====================

- 修改Guest系统的 ``/etc/sudoers`` 允许 ``sudo`` 用户组可以无密码执行::

   #%sudo    ALL=(ALL:ALL) ALL
   %sudo    ALL=(ALL:ALL) NOPASSWD:ALL

- 参考 :ref:`netplan_static_ip` 设置好Guest虚拟机的静态IP地址，便于后续clone出虚拟机后调整

- 在用户目录 ``~/.ssh/authorized_keys`` 中添加Host物理主机的公钥，以便能够方便登陆管理

- 对齐物理主机、工作主机和虚拟机中同名账号的uid和gid

.. note::

   CentOS/RHEL 默认新开设的第一个账号的 ``uid/gid`` 是 ``501/20`` ，为方便各个虚拟机之间免密同账号登陆，将所有平台的自己个人账号的 ``uid/gid`` 对齐，以便避免权限错乱。

- 安装后登陆Guest系统内部更新系统并安装必要软件::

   sudo apt update
   sudo apt upgrade
   sudo apt install screen net-tools nmon 

准备虚拟机的动态调整
======================

- 配置模版虚拟机的 ``setmaxmem`` 和手工修改配置，以便后续能够根据需要动态修改虚拟机的vcpu和mem::

   virsh setmaxmem ubuntu18.04 16G

不过，设置最大vcpu数量方法没有直接的virsh命令，所以采用 ``virsh edit ubuntu18.04`` 方法，将以下配置::

   <vcpu placement='static'>1</vcpu>

修改成::

   <vcpu placement='static' current='1'>8</vcpu>

.. note::

   详细的动态修改虚拟机vcpu和memory的方法参考 `动态调整KVM虚拟机内存和vcpu实战 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/add_remove_vcpu_memory_to_guest_on_fly.md>`_

下一步
===========

现在我们已经创建了第一个可用的KVM虚拟机，并且对虚拟机做了调整。现在用这个虚拟机作为模版，我们可以快速clone出实验所需的虚拟机：

- :ref:`clone_vm`
