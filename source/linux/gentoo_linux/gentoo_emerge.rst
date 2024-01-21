.. _gentoo_emerge:

===================
Gentoo emerge
===================

``emerge`` 是 ``Portage`` 的命令行接口，也就是大多数用户和Portage交互所使用的，是Gentoo Linux最重要的命令之一。

``emerge`` 可以提供有关将进行的哪些更改的丰富输出，并提供各个包或系统的信息和警告。 ``--ask`` / ``--pretend`` / ``--verbose`` 选项可以让Portage显示更多有用信息。

常用参数组合
==============

- ``-atv`` 表示 ``--ask`` , ``--tree`` 和 ``--verbose`` ，可以让 ``emerge`` 在实际执行前询问，显示软件包依赖树关系，以及详细的输出信息:

.. literalinclude:: ../desktop/tmux/gentoo_tmux
   :caption: gentoo安装tmux

在输出信息中分别有以下状态字符表明一个软件包将要进行的动作:

- ``U`` : upgrade, 该软件包将要被升级
- ``D`` : downgrade, 该软件包将要被降级
- ``R`` : re-emerge, 该软件包将要重新编译安装
- ``N`` : new, 该软件包是新安装

- ``--search`` 参数提供了搜索软件包名关键字, ``--searchdesc`` 则软件包名和描述的关键字，并且搜索支持正则表达式:

.. literalinclude:: gentoo_emerge/search
   :caption: ``emerge`` 的搜索功能案例

删除(uninstall)软件包
=======================

在Gentoo中，卸载(uninstall)软件包的命令参数是 ``--depclean`` ，缩写是 ``-c`` ，所以通常可以使用如下命令(案例是卸载 :ref:`nginx` ):

.. literalinclude:: gentoo_emerge/uninstall_nginx
   :caption: 使用 ``emerge`` 卸载 :ref:`nginx`

.. note::

   不要混淆 ``-c`` ( ``--depclean`` )参数和 ``-C`` ( ``--unmerge`` )参数:

   - ``-c`` ( ``--depclean``  )参数是安全的，不会破坏系统
   -  ``-C`` ( ``--unmerge``  )是高风险参数，能够删除影响系统运行的关键软件包， **不要使用 -C (大写)参数**

清理孤儿软件包
==================

清理孤儿软件包分两个步骤:

- 首先完成完整的 :ref:`upgrade_gentoo` :

.. literalinclude:: upgrade_gentoo/emaint_short
   :language: bash
   :caption: 使用emaint更新仓库

.. literalinclude:: upgrade_gentoo/emerge_world_short
   :language: bash
   :caption: 使用emerge升级整个系统

- 然后结合 ``--ask --depclean`` 参数清理孤儿软件包:

.. literalinclude:: gentoo_emerge/depclean
   :caption: 结合 ``--ask --depclean`` 参数清理孤儿软件包

保留特定软件包
=================

可以通过 ``--noreplace`` 参数来确保某个软件包不被 ``emerge --depclean`` 清理掉::

   emerge --noreplace <atom>

检查"孤儿"软件包
===================

``eix`` ( ``app-portage/eix`` )工具可以检查孤儿软件包::

   eix-test-obsolete

``emerge`` 代理
====================

一些emerge使用了GitHub的git仓库，此时会遇到GFW的阻塞导致无法完成安装部署。解决的方法是使用 :ref:`proxychains` 来强制tcp连接通过代理服务器，例如 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建的 ``socks5`` 代理

参考
=====

- `gentoo linux wiki: emerge <https://wiki.gentoo.org/wiki/Emerge>`_
