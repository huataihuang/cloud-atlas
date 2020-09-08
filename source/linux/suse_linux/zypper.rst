.. _zypper:

=========================
zypper - SUSE包管理工具
=========================

Zypper 是一个命令行包管理器，用于安装、更新和删除软件包以及管理软件仓库。可以方便我们远程管理软件或者通过shell完成软件管理。

zypper的简单格式是跟随一个命令，例如应用补丁::

   zypper patch

如果希望以非交互方式运行程序(例如在脚本中)，则使用参数 ``--non-interactive`` ::

   zypper --non-interactive patch

zypper提供了一个模拟执行选项 ``--dry-run`` 可以模拟命令但实际不执行，通常用于测试::

   zypper remove --dry-run MozillaFirefox

.. note::

   OpenSUSE提供了一个 `Zypper Cheat Sheet <https://en.opensuse.org/images/1/17/Zypper-cheat-sheet-1.pdf>`_ 快速命令查询，可以方便我们对照找到使用方法。

软件仓库
===========

- 首先我们检查软件仓库::

   zypper repos
   # 或者
   zypper lr

此时显示输出举例::

   Repository priorities are without effect. All enabled repositories share the same priority.
   
   # | Alias             | Name              | Enabled | GPG Check | Refresh
   --+-------------------+-------------------+---------+-----------+--------
   1 | SLES12-SP3-12.3-0 | SLES12-SP3-12.3-0 | No      | ----      | ----

这说明我们的安装系统已经配置了一个 ``SLES12-SP3-12.3-0`` 仓库，但是并没有激活。

通过 ``-u`` 参数还可以详细显示仓库的url::

   zypper lr -u

显示输出::

   # | Alias             | Name              | Enabled | GPG Check | Refresh | URI                                                                                           
   --+-------------------+-------------------+---------+-----------+---------+-----------------------------------------------------------------------------------------------
   1 | SLES12-SP3-12.3-0 | SLES12-SP3-12.3-0 | No      | ----      | ----    | hd:///?device=/dev/disk/by-id/usb-Kingston_DataTraveler_3.0_0C9D9210E304F440990A0478-0:0-part2

原来这个仓库是本地安装U盘，当前已经移除。

- 添加安装源::

   zypper ar http://download.opensuse.org/update/12.3/ update


然后再次检查 ``zypper lr`` 则显示::

   # | Alias             | Name              | Enabled | GPG Check | Refresh
   --+-------------------+-------------------+---------+-----------+--------
   1 | SLES12-SP3-12.3-0 | SLES12-SP3-12.3-0 | No      | ----      | ----   
   2 | update            | update            | Yes     | ( p ) Yes  | No

- 上述软件仓库名字 ``update`` 不清晰，所以我们可以修改软件仓库名字::

   zypper nr 2 opensuse-12.3-update

提示::

   Repository 'update' renamed to 'opensuse-12.3-update'.

再次检查 ``zypper lr`` 显示名字已经修订::

   # | Alias                | Name                 | Enabled | GPG Check | Refresh
   --+----------------------+----------------------+---------+-----------+--------
   1 | SLES12-SP3-12.3-0    | SLES12-SP3-12.3-0    | No      | ----      | ----   
   2 | opensuse-12.3-update | opensuse-12.3-update | Yes     | ( p ) Yes  | No

- 如果我们要移除仓库，例如刚才添加的仓库 ``opensuse-12.3-update`` 则使用命令::

   zypper rr opensuse-12.3-update

.. note::

   现在你基本上应该已经有些感觉了，SUSE的zypper管理命令使用了很多字母缩写，例如::

      removerepo = rr
      namerepo = nr
      addrepo = ar

SUSE Package Hub仓库
======================

除了可以添加OpenSUSE的仓库，对于 SUSE Linux Enterprise Server 12还可以添加 SUSE Package Hub仓库，这个SUSE Package Hub仓库是由使用SUSE Open Build Service的社区提供构建和维护的，这样就可以用于安装SUSE Linux Enterprise Server和Desktop系统的软件包，而不需要自己重新编译。注意，这些软件包不是由SUSE官方直接支持的，但是SLES和SLED系统在使用这些软件包之后依然提供支持。

注意，SUSE Package Hub软件包不能替代或更新SUSE支持的软件包。

操作步骤
-----------

- 注册SUSE产品： https://www.suse.com/documentation/sles-12/book_sle_deployment/data/sec_i_yast2_conf_manual_cc.html

- 激活SUSE Package Hub extension

有两种方式激活：

通过 YaST2::

   yast -> software
     -> Add-on Products
        -> Add
          -> Extensions and Modules from Registration Server...
            -> SUSE Package Hub   

或者通过SUSEConnect::

   SUSEConnect -p PackageHub/12.1/x86_64

以上案例是针对 SUSE Linux Enterprise 12 SP1，如果是其他版本，例如 SUSE Linux Enterprise 12 SP2 则为::

   SUSEConnect -p PackageHub/12.2/x86_64

依次类推。

.. note::

   使用以下命令可以列出所有可用模块和扩展::

      SUSEConnect --list-extensions

参考
=====

- `SDB:Zypper 用法 <https://zh.opensuse.org/SDB:Zypper_用法>`_
- `45 Zypper Commands to Manage ‘Suse’ Linux Package Management <https://www.tecmint.com/zypper-commands-to-manage-suse-linux-package-management/>`_ - 这篇文档比较实用，可以参考学习
- `SUSE文档：使用命令行工具管理软件 <https://documentation.suse.com/zh-cn/sles/12-SP3/html/SLES-all/cha-sw-cl.html#sec-zypper>`_ - 详细的SUSE管理手册
- `Adding SUSE Package Hub repositories to SUSE Linux Enterprise Server 12 <https://www.suse.com/support/kb/doc/?id=000018789>`_
