.. _freebsd_packages_ports:

======================================
FreeBSD应用程序安装:Packages和Ports
======================================

FreeBSD在核心系统的基础上提供了两种技术来安装第三方软件:

- FreeBSD Ports Collection: 从源代码安装第三方软件
- packages: 安装预先编译的执行代码

FreeBSD port是一组设计成自动编译程序的文件集合，提供了所有自动下载、解压、补丁、编译和安装应用程序的所有信息。目前有超过36000个第三方软件已经ported到了FreeBSD。

FreeBSD的packages和ports都能够处理软件包依赖，虽然两者都能达成目标，但是取决于你的需求:

- Package优点:

  - 预编译软件tar包通常比源代码tar包压缩得更小
  - Package不需要编译时间，对于大型程序，例如Firefox, KDE Plasma 或 GNOME，在缓慢的主机上使用Package较为合适
  - Package不要求使用者理解FreeBSD上编译软件的过程

- Port优点:

  - Package通常是为最大使用的系统编译的，所以参数没有优化，而使用port编译，可以修订编译参数
  - 一些应用程序的编译时间依赖于安装的功能，例如 :ref:`nginx` 有大量的不同编译选项，提供了一个 ``nginx`` 软件包和一个 ``nginx-lite`` 软件包:

    - 由于激活了大量的选项，nginx安装实际需要很多依赖，导致更多的空间要求、也增加了攻击面
    - 由于安装依赖增长巨大，完整的nginx软件包甚至会(令人惊讶)需要一些X库
    - 只有通过 ``prot`` 安装 ningx才能从源代码定制出真正需要选项，一方面增强性能一方面降低了安全隐患

  - 由于license的限制部分软件不能以二进制发布，则必须在终端用户这里编译
  - 有些用户不信任二进制程序，需要检查源代码是否存在风险
  - 源代码适合一些定制补丁

.. warning::

   在安装应用程序之前，请检查 https://vuxml.freebsd.org/ 的相关安全信息

   要审计已经安装的软件是否存在已知漏洞，请运行 ``pkg audit -F``

查找软件
==========

FreeBSD提供了一些方法来列出不断增长的软件;

- `Ports Portal <https://ports.freebsd.org/>`_ 可以按照软件分类搜索
- `FreshPorts <https://www.freshports.org/>`_ 提供了完善的搜索工具并跟踪应用程序在Ports Collection中的变化
- 可以在 `SourceForge <https://sourceforge.net/>`_ 或 `GitHub <https://github.com/>`_ 查找应用程序，然后再回到 `Ports Portal <https://ports.freebsd.org/>`_ 查看该应用是否已经被ported到FreeBSD了
- 使用 ``pkg`` 命令可以搜索二进制软件包仓库

.. _freebsd_pkg:

``pkg`` 管理二进制软件包
==========================

.. _freebsd_ports:

``ports`` Collection
========================

安装Ports Collection
-----------------------

在使用 ``port`` 来编译一个程序之前，首先必须安装好 ``Port Collection`` ：

- 首先系统需要具备 :ref:`git` 来维护ports tree:

.. literalinclude:: freebsd_packages_ports/pkg_install_git
   :caption: 安装git

或者通过 ``ports`` 来安装git:

.. literalinclude:: freebsd_packages_ports/ports_install_git
   :caption: ports安装git

- ``check out`` ports 的HEAD分支:

.. literalinclude:: freebsd_packages_ports/git_checkout_ports
   :caption: ``check out`` ports 的HEAD分支

也可以 ``check out`` 特定的quarterly分支:

.. literalinclude:: freebsd_packages_ports/git_checkout_quarterly_ports
   :caption: ``check out`` ports 的quarterly分支

- 如果需要，在初始 ``git`` checkout之后，更新 ``/usr/ports``

.. literalinclude:: freebsd_packages_ports/git_pull_ports
   :caption: ``git`` 更新 ``/usr/ports``

如果需要，也可以切换到不同的quarterly分支，例如:

.. literalinclude:: freebsd_packages_ports/git_switch_ports
   :caption: ``git`` 切换 ``/usr/ports``

安装ports
------------

- 以下举例 ``lsof`` 安装:

.. literalinclude:: freebsd_packages_ports/ports_lsof
   :caption: 使用 ``ports`` 安装 ``lsof``

移除ports
-----------

- 移除使用 ``deinstall`` :

.. literalinclude:: freebsd_packages_ports/ports_deinstall_lsof
   :caption: 使用 ``deinstall`` 移除已经安装的ports

升级ports
-----------

- 执行以下命令检查系统是否有可以升级的ports(注意需要先更新 ``/usr/ports`` )

.. literalinclude:: freebsd_packages_ports/check_ports
   :caption: 检查ports是否有可更新已安装的软件

- 安装 ``portmaster`` (管理ports升级工具):

.. literalinclude:: freebsd_packages_ports/install_portmaster
   :caption: 安装 ``portmaster``

- 使用 portmaster 进行更新:

.. literalinclude:: freebsd_packages_ports/portmaster
   :caption: 使用 ``portmaster`` 进行更新

参考
======

- `FreeBSD Handbook: Chapter 4. Installing Applications: Packages and Ports <https://docs.freebsd.org/en/books/handbook/ports/>`_
