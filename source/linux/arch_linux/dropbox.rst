.. _arch_linux_dropbox:

=========================
Arch Linux上使用Dropbox
=========================

Dropbox是目前我使用过最好的网盘:

- 跨平台数据同步：特别是支持Linux操作系统，就远比iCloud同步优秀多了
- 数据同步准确迅速：曾经使用过iCloud同步，然而同步延迟以及错综复杂的本地和远程映射导致的数据长时间无法同步，使得我不得不放弃macOS的iCloud文件同步。Dropbox在这方卖弄具有完全的优势。

.. note::

   从2019年7月，Dropbox Client build 77.3.127恢复支持ZFS,eCryptfs,xffs和btrfs(2018年11月曾今一度中断了除Ext4以外Linux其他文件系统支持，总算顺应用户要求恢复了多文件系统支持)。

安装Dropbox
===============

- 通过 :ref:`archlinux_aur` 安装Dropbox::

   yay -S dropbox

- 安装可选软件包，我根据我使用的 :ref:`xfce` 桌面安装 Thunar 集成::

   yay -S thunar-dropbox

使用Dropbox
================

安装完成后，通过命令行运行 ``dropbox`` 或者菜单点击 Dropbox 启动图形界面。会通过WEB引导设置，完成设置后，将自动开始同步数据到 ``~/Dropbox`` 目录。

- 避免dropbox自动升级(即将Dropbox的自动升级目录 ``~/.dropbox-dist/`` 替换成只读目录) ::

   rm -rf ~/.dropbox-dist
   install -dm0 ~/.dropbox-dist

- 设置自动启动:

有多种设置自动启动dropbox的方法，可以采用systemd自动启动::

   systemctl enable dropbox@username

这里 ``username`` 请替换成你自己的帐号名。

不过，使用服务方式运行dropbox不会在X window的桌面托盘中显示dropbox图表，则编辑::

   systemctl edit dropbox@username

添加内容如下::

   [Service]
   Environment=DISPLAY=:0

然后通过 ``systemctl cat dropbox@username`` 可以检查服务启动配置。

参考
=======

- `Arch Linux社区文档 - Dropbox <https://wiki.archlinux.org/index.php/Dropbox>`_
