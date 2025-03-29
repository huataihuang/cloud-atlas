.. _archlinux_snap:

====================
Arch Linux运行snap
====================

正如 :ref:`anbox_scratch` 提到的，在snap容器运行环境中，可以运行很多有趣的应用，例如微信。在Arch Linux下也能够安装运行snap运行环境，这样可以方便使用很多桌面软件。

安装snap环境
================

- 安装snapd::

   yay -S snapd

.. note::

   ``snapd`` 安装了一个脚本在 ``/etc/profile.d/snapd.sh`` 来输出所有安装的snapd包和桌面入口的路径，所以要重启一次系统才能生效。

启用snapd::

   systemctl enable snapd
   systemctl start snapd

- (可选)激活apparmor可以将snap程序运行在受限制的沙箱内，提供更好的安全性(如果不使用AppArmor就会让所有snaps运行在 ``devel`` 模式，也就是没有限制地访问系统，就好像普通应用程序)::

   systemctl enable --now apparmor.service
   systemctl enable --now snapd.apparmor.service

使用snap
==========

- 查找可用的snap::

   snap find searchterm

- 安装::

   snap install snapname

注意安装需要root权限。会创建每个snap的挂载但愿，并将其加入到 ``/etc/systemd/system/multi-user.target.wants/`` 作为软连接，以便系统启动时所有snaps就绪。

- 显示已经安装的snap::

   snap list

- 更新::

   snap refresh

- 删除::

   snap remove snapname

.. note::

   一些snap，例如 Skype 和 Pycharm 使用经典配置，需要 ``/snap`` 目录，不是 FHS兼容，则需要手工创建::

      ln -s /var/lib/snapd/snap /snap

安装微信
=========

- 安装::

   sudo snap install electronic-wechat
