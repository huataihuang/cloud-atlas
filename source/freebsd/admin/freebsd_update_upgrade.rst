.. _freebsd_update_upgrade:

======================
FreeBSD更新和升级
======================

FreeBSD在发行不同relase期间会持续开发: 有些人会倾向于使用官方发布版本，有些人则喜欢和最新的开发版本保持同步。不管怎样，每个官方发行版都会有安全更新和其他关键修复。不管使用哪个版本，FreeBSD都提供了必要工具来保持系统更新以及易于在不同版本之间的升级工具。

.. note::

   在大陆访问FreeBSD的更新网站非常缓慢，甚至无法完成更新。所以可能需要设置 :ref:`freebsd_proxy`

FreeBSD update
=================

FreeBSD提供了一个名为 ``freebsd-update`` 的工具来提供安全补丁以及更新到新发行版本的能力。该工具支持二进制安全和更新，不需要手工编译和对内核补丁。二进制更新是对所有架构提供，并且通过安全团队提供当前版本支持。有关发行版支持和产品生命周期时间，请参考 https://www.FreeBSD.org/security/

对于需要更新版本号的操作，请参考 https://www.FreeBSD.org/releases/ 信息

配置文件
-------------

``/etc/freebsd-update.conf`` 配置文件控制了 ``freebsd-update`` 工具的工作方式，例如可以微调升级过程。默认配置是升级整个 ``base`` 系统和内核。

安全补丁
-----------

- 执行以下命令完成 security 和 errate patches安装更新:

.. literalinclude:: freebsd_update_upgrade/freebsd-update_fetch_install
   :caption: 安装安全和修正补丁

版本升级
=============

- minor version upgrades: 例如 FreeBSD 13.1 升级到 13.2
- major version upgrades: 例如 FreeBSD 13.2 升级到 14.0

上述版本升级都可以通过 ``freebsd-update`` 工具完成

- 我的实践: FreeBSD 13.0 升级到 14.2:

.. literalinclude:: freebsd_update_upgrade/freebsd-update_14.2
   :caption: FreeBSD 13.0 升级到 14.2

输出:

.. literalinclude:: freebsd_update_upgrade/freebsd-update_14.2_output
   :caption: FreeBSD 13.0 升级到 14.2 的输出
   :emphasize-lines: 14

有些升级配置会提示你冲突而无法合并，此时需要按照提示进行编辑，将你认为合理的配置保留，不需要的配置删除

.. literalinclude:: freebsd_update_upgrade/freebsd-update_14.2_merge
   :caption: 升级过程会提示冲突的配置，需要手工编辑
   :emphasize-lines: 4

最终完成配置之后，会提示可以执行如下命令进程安装:

.. literalinclude:: freebsd_update_upgrade/freebsd-update_14.2_install
   :caption: 解决了冲突的配置后会提示执行如下命令安装

- 现在开始正式安装升级版本:

.. literalinclude:: freebsd_update_upgrade/freebsd-update_install
   :caption: 确认无误后开始正式安装升级包

安装完成后提示需要重启并再次执行 ``freebsd-update install`` :

.. literalinclude:: freebsd_update_upgrade/freebsd-update_install_output
   :caption: 安装完成后提示需要重启并再次执行 ``freebsd-update install``

- 重启 ``reboot`` 并按照提示再执行一次

.. literalinclude:: freebsd_update_upgrade/freebsd-update_install
   :caption: 重启后再次执行install

提示升级移除了旧的共享对象文件，并且有一个提示显示需要重建第三方软件(例如从 ``ports`` 中安装的程序)，并且需要在完成第三方软件重建后，再次执行 install

.. literalinclude:: freebsd_update_upgrade/freebsd-update_install_output_again
   :caption: 提示信息需要重建第三方程序

RELEASE升级问题排查
======================

我在尝试 ``14.2-RELEASE`` 升级版本到 ``14.3-RELEASE`` 的时候总是遇到文件 ``fetch`` 错误:

.. literalinclude:: freebsd_update_upgrade/fetch_error
   :caption: 版本升级时fetch错误
   :emphasize-lines: 17-29

最初我考虑是受到GFW影响，所以我尝试 :ref:`freebsd_proxy` 设置，但是报错依旧。

我又尝试了 `FreeBSD-update: gunzip: (stdin): unexpected end of file metadata is corrupt error <https://www.nixcraft.com/t/freebsd-update-gunzip-stdin-unexpected-end-of-file-metadata-is-corrupt-error/3784>`_ 介绍的两种方法:

- 先尝试清理掉本地已经下载的缓存文件:

.. literalinclude:: freebsd_update_upgrade/clean_update_cache
   :caption: 清理本地缓存的升级文件

但是依然报错 ``gunzip: (stdin): unexpected end of file e02141215d8bac9351822518f491b7adb8629d379da8d6778d4c5a2b6f34affb has incorrect hash.``

- 尝试第二个方法是修订 ``/etc/freebsd-update.conf`` ，将 ``ServerName`` 调整为 ``update2.FreeBSD.org`` 服务器:

.. literalinclude:: freebsd_update_upgrade/freebsd-update.conf
   :caption: 修订升级服务器配置
   :emphasize-lines: 6

然后重新执行RELEASE升级。实践验证，方法二成功

参考
======

- `FreeBSD Handbook: Chapter 26. Updating and Upgrading FreeBSD <https://docs.freebsd.org/en/books/handbook/cutting-edge/>`_
- `FreeBSD-update: gunzip: (stdin): unexpected end of file metadata is corrupt error <https://www.nixcraft.com/t/freebsd-update-gunzip-stdin-unexpected-end-of-file-metadata-is-corrupt-error/3784>`_
