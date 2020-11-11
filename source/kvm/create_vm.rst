.. _create_vm:

=============================
Studio环境创建KVM虚拟机
=============================

.. note::

   在Studio环境中，KVM虚拟化是实现模拟数据中心的核心。因为单纯的Docker+Kubernetes无法模拟多台物理服务器，虽然容器技术更为轻量级。

   为Studio选择的默认Guest操作系统是Ubuntu 18.04，这样可以获得Kernel 4.15，并且得到LTS长期支持。这个基础Guest系统将用于构建OpenStack。

   Studio环境采用Ubuntu作为host和guest的OS，在 :ref:`real` 中， :ref:`priv_kvm` 则采用CentOS作为OS。

创建CentOS 7虚拟机
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

   - 使用 ``osinfo-query os`` 可以查询出 ``--os-variant`` 所有支持的参数，这样可以精确指定操作系统版本以便优化运行参数。
   - ``--graphics none`` 表示不使用VNC来访问VM的控制台，而是使用VM串口的字符控制台。
   - ```--location`` 指定通过网络安装，如果使用本地iso安装，则使用 ``--cdrom /var/lib/libvirt/images/ubuntu-18.04.2-live-server-amd64.iso``
   - 只有通过网络安装才可以使用 ``--extra-args="console=tty0 console=ttyS0,115200"`` 以便能够通过串口控制台安装
   - 要模拟UEFI，需要安装 ``ovmf`` 软件包，并使用参数 ``--boot uefi``
   - root分区采用EXT4文件系统，占据整个磁盘
   - 软件包只选择 ``OpenSSH server`` 以便保持最小化安装，后续clone出的镜像再按需安装

   上述安装是通过 ``virsh console`` 连接到虚拟机的串口控制台实现的，安装完成后，需要 ``detach`` 断开串口控制台: ``CTRL+Shift+]`` ，这就可以返回host主机的控制台。

.. note::

   在KVM中部署和运行Windows虚拟机相对复杂，请参考 :ref:`deploy_win_vm`

创建CentOS 8虚拟机
------------------

- CentOS 8虚拟机安装::

   virt-install \
     --network bridge:virbr0 \
     --name centos8 \
     --ram=4096 \
     --vcpus=2 \
     --os-variant=rhel8.0 \
     --disk path=/var/lib/libvirt/images/centos8.qcow2,format=qcow2,bus=virtio,cache=none,size=8 \
     --graphics spice \
     --cdrom=/var/lib/libvirt/images/CentOS-8-x86_64-1905-boot.iso

- 安装过程的 ``installation source`` 设置为 ``http://mirrors.163.com/centos/8.0.1905/BaseOS/x86_64/os/`` (URL type是 ``repository URL`` ) 然后点击 ``Done`` 则自动刷新验证，最后显示的安装源如下：

.. figure:: ../_static/kvm/centos8_installation_source.png

创建SUSE虚拟机
================

- 部署suse server 12 sp3::

   virt-install \
     --network bridge:virbr0 \
     --name sles12-sp3 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=sles12sp3 \
     --disk path=/var/lib/libvirt/images/sles12-sp3.qcow2,format=qcow2,bus=virtio,cache=none,size=16 \
     --graphics vnc \
     --cdrom=/var/lib/libvirt/images/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso

这里输出有一个警告提示::

   WARNING  Graphics requested but DISPLAY is not set. Not running virt-viewer.
   WARNING  No console to launch for the guest, defaulting to --wait -1

   Starting install...
   Allocating 'sles12-sp3.qcow2'                             |  16 GB  00:00

   Domain is still running. Installation may be in progress.
   Waiting for the installation to complete.

.. note::

   参数 ``--graphics vnc`` 会在服务器本地回环地址 ``127.0.0.1`` 上启动VNC监听，可以通过 ``virsh vncdisplay <vm_name>`` 查看::

      virsh vncdispaly sles12-sp3

   例如输出::

      127.0.0.1:0

   则可以使用ssh端口转发登陆服务器::

      ssh -L 5900:127.0.0.1:5900 <username>@<server_ip>

   也可以配置 ``~/.ssh/config`` 中添加配置::

      Host server_name
          HostName server_ip
          User huatai
          LocalForward 5900 127.0.0.1:5900

   然后执行::

      ssh -C server_name

   就可以实现同样的ssh端口转发。

.. note::

   KVM提供的VNC访问方式在macOS上需要使用第三方VNC客户端来访问，例如 `TigerVNC <https://tigervnc.org>`_ ，使用macOS内置的vnc无法打开访问。使用VNC客户端访问本地 ``127.0.0.1:5900`` 则可以看到远程虚拟机的终端界面，就可以开始进一步安装:

   .. figure:: ../_static/kvm/tigervnc_install_sles12.png
      :scale: 75

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
