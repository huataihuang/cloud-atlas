.. _gentoo_equery:

====================
Gentoo Equery
====================

``equery`` 是一个非常有用的Portage操作简化工具，并且提供了包依赖，元数据和安装文件的查询功能。

安装
========

- 安装 gentoolkit 工具包就可以获得 ``equery`` :

.. literalinclude:: gentoo_equery/gentoolkit
   :caption: 安装 ``app-portage/gentoolkit`` 获得 ``equery``

使用
========

已安裝軟件包版本查詢
---------------------

- 检查已经安装的软件包版本:

.. literalinclude:: gentoo_emerge/list_installed
   :caption: 检查系统已经安装的软件包版本

- 检查 glibc 安装版本( 因为我在 :ref:`gentoo_image` 构建的容器中遇到了 :ref:`upgrade_gentoo` 的32位兼容性问题，需要pin住glibc版本不升级):

.. literalinclude:: gentoo_equery/equery_glibc
   :caption: 检查主机安装的 ``glibc`` 版本

然后就能够对应 :ref:`pin_gentoo_package_version`

軟件包USE參數查詢
------------------

- Firefox的 ``ebuild`` 有大量的USE参数，可以通过如下命令检查:

.. literalinclude:: gentoo_firefox/equery
   :caption: 通过 ``equery`` 查询 ``www-client/firefox`` 的USE参数

参考
=======

- `gentoo wiki: Equery <https://wiki.gentoo.org/wiki/Equery>`_
