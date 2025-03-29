.. _gentoo_update_profile:

=========================
Gentoo升级profile
=========================

大约两个月没有使用Gentoo，最近一次 :ref:`gentoo_emerge` 升级，发现提示有最新的profile需要切换:

.. literalinclude:: gentoo_update_profile/emerge_output
   :emphasize-lines: 9

.. note::

   本文为一次profile实践笔记，作为大版本profile升级参考。具体升级方法，需要参考官方提示

升级profile提示概述
===========================

- 需要确保 ``CHOST`` 配置符合要求(默认配置不要修改)
- 确保系统已经备份并且已经更新早最新版本: 不支持低于2.36版本的glibc和低于1.2.4的musl
- 如果仍然在使用已经长期废弃的amd 17.0 profiles(和x32或musl不同)，则需要首先迁移到相应的17.1 profile
- 如果当前使用split-user配置的 :ref:`systemd` ，则首先需要迁移到正确的 merged-usr prfile(相同的profile版本)
- 如果当前使用 :ref:`openrc` 则首先迁移到 23.0，如果想从split-usr改成merged-usr，需要在迁移23.0之后执行
- 检查 ``emerge --info`` 输出信息，查看 ``CHOST`` 变量，我的输出是::

   CHOST="x86_64-pc-linux-gnu"

- 编辑 ``/etc/portage/make.conf`` **如果有 CHOST 变量，需要删除掉这个变量** 也要删除掉所有定义 ``CHOST_...`` 变量
- 通过 ``eselect profile`` 选择(或者手工修改符号连接)，但是需要注意旧版本profile默认是 ``split-usr`` ，而 23.0 profile默认是 ``merged-usr`` : 请根据 `Gentoo Project:Toolchain/23.0 update table <https://wiki.gentoo.org/wiki/Project:Toolchain/23.0_update_table>`_ 选择升级的profile，基本规律是如果是 :ref:`systemd` 系统，则需要先参考 `/usr merge for systemd users <https://www.gentoo.org/support/news-items/2022-12-01-systemd-usrmerge.html>`_ 迁移到 ``merged-user`` ，然后再做profile升级(需要执行 ``merge-usr`` 工具)

.. note::

   所谓 ``merged-usr`` 是指从 2023 年年中开始， :ref:`systemd` 不再支持 ``split-usr/unmerged-usr`` 系统，必须将原先的 ``/bin`` , ``/sbin`` , ``/lib`` 迁移到 ``/usr/bin`` ``/usr/sbin`` 和 ``/usr/lib`` 目录。所有位于 ``/`` 目录下的系统目录则建立软链接。  

确保新的profile使用了相同的属性: 例如旧版(这里以我自己的案例 ``eselect profile list`` 输出)

.. literalinclude:: gentoo_update_profile/profile_17.1
   :emphasize-lines: 4,10,16

则应该先升级到 23.0 的相同的 ``split-usr`` (上述第16行)： 对于 :ref:`openrc` 系统，没有类似 :ref:`systemd` 强制转换成 ``merged-usr`` 的要求，所以我的修订profile是:

.. literalinclude:: gentoo_update_profile/profile_23
   :language: bash
   :emphasize-lines: 2

- 删除缓存目录的二进制包:

.. literalinclude:: gentoo_update_profile/delete_cache
   :language: bash

- 重新编译或者重新安装二进制包，顺序如下:

.. literalinclude:: gentoo_update_profile/emerge
   :language: bash

- 重新运行 ``emerge --info`` 检查CHOST输出，看是否和前面执行这个命令的 CHOST 一致:

  - 如果一致，则直接执行 ``env-update && source /etc/profile``
  - 如果不一致，则需要(我没有实践，因为我检查前后两次 ``emerge --info`` 输出的 ``CHOST`` 变量一致)

    - 重新检查 ``binutils-config`` 和 ``gcc-config`` 验证安装的binutils和gcc版本
    - 检查 ``/etc/env.d`` , ``/etc/env.d/binutils`` 和 ``/etc/ev.d/gcc`` 确保没有 **旧** 的CHOST值引用，并移除

- 重新 :ref:`gentoo_emerge` ``libtool`` :

.. literalinclude:: gentoo_update_profile/re-emerge_libtool
   :language: bash

- 出于安全考虑，删除缓存 ``${PKGDIR}`` 目录下的二进制软件包缓存:

.. literalinclude:: gentoo_update_profile/delete_cache
   :language: bash

- 最后，重建world:

.. literalinclude:: gentoo_update_profile/rebuild_world
   :language: bash





