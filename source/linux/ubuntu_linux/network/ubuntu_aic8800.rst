.. _ubuntu_aic8800:

========================================
Ubuntu AIC8800驱动(Tenda无线网卡AX300)
========================================

在 :ref:`gentoo_mba_wifi` 实践中，我使用了 ``aic8800`` 芯片的 ``AX300`` 免驱动WiFi6无线网卡，现在我需要在我的 :ref:`priv_cloud_infra` 的底座 ``zcloud`` 使用同款WiFi6 USB无线网卡。

``zcloud`` 使用了 :ref:`ubuntu_linux` ，根据 `Tenda官网: 免驱USB无线网卡系列安装指南 <https://www.tenda.com.cn/download/detail-3706.html>`_ 提供信息，这款AX300官方提供了Linux系统驱

官方驱动软件包中包含了Linux系统安装指南的pdf文档，本文即参考指南完成。

- 解压缩下载的驱动zip文件包，在目录下有一个名为 ``AX300-WiFi-Adapter-Linux-Driver-amd64.deb`` ，可以直接在 :ref:`ubuntu_linux` 中安装:

.. literalinclude:: ubuntu_aic8800/dpkg_install_aic8800
   :caption: 官方提供的deb安装方式编译安装AIC8800驱动

实际过程也就是编译内核模块进行安装

git仓库安装
==============

`GitHub: lynxlikenation/aic8800 <https://github.com/lynxlikenation/aic8800?tab=readme-ov-file>`_ 将代码库上传到GitHub，所以也可以参考 `Help to get driver for Tenda wireless wifi adapter (AX300 w311mi) <https://askubuntu.com/questions/1499222/help-to-get-driver-for-tenda-wireless-wifi-adapter-ax300-w311mi>`_ 从这个仓库 :ref:`git` 方式clone出代码进行编译。

- 安装(记录未实践):

.. literalinclude:: ubuntu_aic8800/git_install_aic8800
   :caption: 通过GitHub仓库中源代码下载编译安装

使用
======

- 安装完成后，重新插入USB wifi，此时使用 ``lsusb`` 命令会看到识别设备如下:

.. literalinclude:: ubuntu_aic8800/lsusb_output
   :caption: 执行 ``lsusb`` 可以查看到驱动安装后识别的AIC8800设备

- 此时执行 ``ifconfig -a`` 命令可以看到系统新增了一个无线设备:

.. literalinclude:: ubuntu_aic8800/ifconfig_output
   :caption: 执行 ``ifconfig -a`` 输出可以看到无线设备
   :emphasize-lines: 1

- 配置 :ref:`wpa_supplicant` 配置文件:

.. literalinclude:: ubuntu_aic8800/wpa_passphrase
   :caption: 通过 ``wpa_passphrase`` 生成配置文件

- 执行wpa_supplicant和dhcpcd:

.. literalinclude:: ubuntu_aic8800/wpa_supplicant
   :caption: 执行 ``wpa_supplicant`` 认证

参考
=======

- `Help to get driver for Tenda wireless wifi adapter (AX300 w311mi) <https://askubuntu.com/questions/1499222/help-to-get-driver-for-tenda-wireless-wifi-adapter-ax300-w311mi>`_
- `Tenda官网: 免驱USB无线网卡系列安装指南 <https://www.tenda.com.cn/download/detail-3706.html>`_
