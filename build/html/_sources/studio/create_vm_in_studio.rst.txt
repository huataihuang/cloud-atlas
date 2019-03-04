.. _create_vm_in_studio:

=============================
Studio环境创建KVM虚拟机
=============================

.. note::

   在Studio环境中，KVM虚拟化是实现模拟数据中心的核心。因为单纯的Docker+Kubernetes无法模拟多台物理服务器，虽然容器技术更为轻量级。

   为Studio选择的默认Guest操作系统是Ubuntu 18.04，这样可以获得Kernel 4.15，并且得到LTS长期支持。这个基础Guest系统将用于构建OpenStack。

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

   - root分区采用EXT4文件系统，占据整个磁盘
   - 软件包只选择 ``OpenSSH server`` 以便保持最小化安装，后续clone出的镜像再按需安装

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

- 修改Guest系统的 ``/etc/sudoers`` 允许 ``sudo`` 用户组可以无密码执行::

   #%sudo    ALL=(ALL:ALL) ALL
   %sudo    ALL=(ALL:ALL) NOPASSWD:ALL

- 在用户目录 ``~/.ssh/authorized_keys`` 中添加Host物理主机的公钥，以便能够方便登陆管理

- 安装后登陆Guest系统内部更新系统并安装必要软件::

   sudo apt update
   sudo apt upgrade
   sudo apt install screen net-tools nmon 
