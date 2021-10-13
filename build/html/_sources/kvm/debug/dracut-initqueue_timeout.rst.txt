.. _dracut-initqueue_timeout:

================================================
CentOS 7虚拟机安装"dracut-initqueue timeout"报错
================================================

我在 :ref:`priv_kvm` Ubuntu上部署CentOS7虚拟机，执行以下方法::

   virt-install \
     --network bridge:br0 \
     --name centos7 \
     --ram=2048 \
     --vcpus=1 \
     --os-type=centos7.0 \
     --disk path=/var/lib/libvirt/images/centos7.qcow2,format=qcow2,bus=virtio,cache=none,size=6 \
     --graphics none \
     --location=http://mirrors.163.com/centos/7/os/x86_64/ \
     --extra-args="console=tty0 console=ttyS0,115200"

但是终端显示报错::

   [  256.670446] dracut-initqueue[737]: Warning: dracut-initqueue timeout - starting timeout scripts
   [  257.191567] dracut-initqueue[737]: Warning: dracut-initqueue timeout - starting timeout scripts
   [  257.192144] dracut-initqueue[737]: Warning: Could not boot.
   [  257.367277] dracut-initqueue[737]: Warning: /dev/root does not exist
            Starting Dracut Emergency Shell...
   Warning: /dev/root does not exist

这个报错通常是因为虚拟机启动或者安装过程中无法识别存储设备导致的，例如无法识别 RAID 设备。在 `RHEL 7 prints "dracut-initqueue timeout - starting timeout scripts" messages in loop while booting <https://access.redhat.com/solutions/2515741>`_ 提供了解决思路(不过这个是指已经运行的服务器无法识别LVM，需要通过内核参数 ``rd.lvm.lv`` 指定启动设备 )

不过，我的情况不同，我在 :ref:`priv_cloud_infrastructure` 采用了交换虚拟网络 ``br0`` ，但是这个 ``br0`` 连接的网络是内部网络 ``192.168.6.0/24`` ，这个网段的主机不能直接访问internet。我忘记通过网络安装虚拟机，虚拟机内部需要直接访问internet，上述报错具有迷惑性。在 `CentOS 7 dracut-initqueue timeout and could not boot – warning /dev/disk/by-id/md-uuid- does not exist <https://ahelpme.com/linux/centos7/centos-7-dracut-initqueue-timeout-and-could-not-boot-warning-dev-disk-by-id-md-uuid-does-not-exist/>`_ 的一个commit提醒了我。

解决的方法我考虑如下:

- 在内部部署一个CentOS/Ubuntu的仓库镜像，这样所有内部服务器都不需要直接访问internet，构架一个数据中心
- 在安装过程中指定代理服务器，因为我在 :ref:`apt_proxy_arch` 实现了本地局域网squid代理

