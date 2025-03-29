.. _edge_jetson:

====================
边缘计算Jetson Nano
====================

在边缘计算ARM集群环境， :ref:`jetson_nano` 作为 :ref:`k3s` 集群的一个工作节点，同时提供 :ref:`xpra` 远程图形工作环境。为提高运行效率，我改进了 :ref:`jetson_nano_startup` 的桌面系统精简方式，采用 :ref:`jetson_xpra` 图形方式来运行。

精简系统
============

- 首先参考 :ref:`jetson_nano_startup` 完成初始安装
- 去除所有不需要的图形办公软件
- 参考 :ref:`jetson_xfce4` 清理掉默认安装的所有桌面程序，但是也不安装Xfce，这是因为后续只安装 :ref:`xpra` 来构建最基本桌面
- :ref:`disable_snap` ，进一步降低系统消耗

清理图形办公软件
-------------------

- 执行以下命令清理Office和Mail软件::

   sudo apt remove --purge libreoffice* -y
   sudo apt remove --purge thunderbird* -y
   sudo apt clean -y
   sudo apt autoremove -y
   sudo apt update

清理桌面Unity
--------------

- 执行以下命令清理Unity深度定制的Gnome3环境::

   sudo apt remove nautilus gnome-power-manager gnome-screensaver gnome-termina* gnome-pane* gnome-applet* gnome-bluetooth gnome-desktop* gnome-sessio* gnome-user* gnome-shell-common compiz compiz* unity unity* hud zeitgeist zeitgeist* python-zeitgeist libzeitgeist* activity-log-manager-common gnome-control-center gnome-screenshot overlay-scrollba*

   sudo apt autoremove

清理snap
-----------

.. note::

   现在默认只安装了 ``snapd`` ，并没有安装各种 ``snap`` 包，所以 ``snap list`` 输出是空的

- 执行以下命令卸载::

   sudo apt purge snapd 
   sudo apt autoremove

配置默认启动字符界面
-----------------------

- 设置字符界面启动::

   rm /etc/systemd/system/default.target
   ln -s /lib/systemd/system/runlevel3.target /etc/systemd/system/default.target

配置用户账号
---------------

- 个人 ``huatai`` 账号调整允许无密码sudo，所以在 ``/etc/sudoers`` 配置中添加一行::

   echo "huatai ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

- 个人 ``huatai`` 账号加入 ``docker`` 组，方便直接运行 ``docker`` 

调整内核
----------

- 由于 :ref:`jetson_pcie_err` ，调整内核参数，修订 ``/boot/extlinux/extlinux.conf`` ，在内核参数上添加 ``pcie_aspm=off``

- 重启系统::

   shutdown -r now


