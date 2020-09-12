.. _ubuntu64bit_pi:

=======================
树莓派4b运行64位Ubuntu
=======================

为了能够充分发挥最新的64位树莓派性能，我采用64位Ubuntu Server进行部署安装，目标是在树莓派上实践64位ARM架构的Linux操作系统，包括但不限于：

- 部署 :ref:`kubernetes`
- 编译和优化64位ARM :ref:`kernel`
- 规模化自动部署ARM集群
- 探索ARM环境编程

无线网络
==========

`How to install Ubuntu on your Raspberry Pi - 3. Wi-Fi or Ethernet <https://ubuntu.com/tutorials/how-to-install-ubuntu-on-your-raspberry-pi#3-wifi-or-ethernet>`_ 提供了一个在安装过程中设置WiFi的步骤，即编辑SD卡的 ``system-boot`` 分区中的 ``network-config`` 文件，去除掉以下段落的注释符号 ``#`` 类似如下::

   wifis:
     wlan0:
     dhcp4: true
     optional: true
     access-points:
       <wifi network name>:
         password: "<wifi password>"

然后保存。然后用这个SD卡首次启动树莓派，就会自动连接WiFi。

Ubuntu for Raspberry Pi默认已经识别了树莓派的无线网卡，之前在 :ref:`ubuntu_on_mbp` 和 :ref:`ubuntu_on_thinkpad_x220` 都使用了NetworkManager :ref:`set-ubuntu-wifi` 。但是这种方式实际上多安装了组件，并且和默认netplan使用的 ``systemd-networkd`` 是完成相同工作，浪费系统内存资源。

所以，建议采用系统已经安装的 ``netplan`` + ``networkd`` 后端来完成无线设置。请参考 :ref:`pi_4_network` 完成设置。
