.. _gentoo_on_gentoo:

============================
在Gentoo上运行Gentoo(容器)
============================

在 :ref:`gentoo_docker` 部署完成后，我期望运行一个非常精简的Gentoo系统底座，而将各种开发、测试等工作搬迁到Gentoo容器中完成:

- 保持物理服务器操作系统尽可能精简稳定
- 容器之间相互隔离
- 方便不断重新实现完全一致的开发测试环境

:ref:`gentoo_image`
=====================

通过 :ref:`gentoo_image` 构建提供ssh服务并且能够安装不同开发环境的基础容器

:ref:`gentoo_docker` 之后进入容器，首先按照 :ref:`install_gentoo_on_mbp` 完成一些必要调整

修改gentoo镜像地址
-----------------------

- :ref:`install_gentoo_on_mbp` 已经提示过，海外的镜像实际上几乎无法访问，所以需要将在 ``/etc/portage/make.conf`` 配置使用国内镜像网站:

.. literalinclude:: gentoo_on_gentoo/gentoo_mirrors
   :language: bash
   :caption: 配置使用阿里云镜像网站
   :emphasize-lines: 2

这步对墙内用户非常重要，否则下载几乎难以完成

.. note::

   为方便修改配置，此时可以先 ``emerge --ask app-editors/vim`` ，当然也可以在后续批量安装

选择profile
------------

- 查看系统当前使用的 ``profile`` :

.. literalinclude:: install_gentoo_on_mbp/eselect_profile_list
   :language: bash
   :caption: 检查当前使用的 ``profile``

可以看到Gentoo容器中默认的 ``profile`` 是最基本的配置:

.. literalinclude:: gentoo_on_gentoo/profile
   :caption: Gentoo的Docker中默认profile是最基本配置
   :emphasize-lines: 1

这里不用修改

更新 @world set
-----------------

更新系统的 ``@world`` set ，以便建立 ``base`` ，这样系统可以应用自构建 ``stage3`` 以来出现的任何更新或 ``USE flag`` 更改以及任何配置文件选择:

.. literalinclude:: install_gentoo_on_mbp/update_world_set
   :language: bash
   :caption: 更新 @world set

配置USE变量
-------------

- 安装工具包:

.. literalinclude:: install_gentoo_on_mbp/install_cpuid2cpuflags
   :language: bash
   :caption: 安装 ``cpuid2cpuflags`` 工具包

- 执行:

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags
   :language: bash
   :caption: 运行 ``cpuid2cpuflags``

- 将输出结果添加到 ``package.use`` :

.. literalinclude:: install_gentoo_on_mbp/cpuid2cpuflags_output_package.use
   :language: bash
   :caption: 运行 ``cpuid2cpuflags`` 输出添加到 ``package.use``

配置时区
----------

配置时区写在 ``/etc/timezone`` 文件:

.. literalinclude:: install_gentoo_on_mbp/timezone
   :language: bash
   :caption: 配置OpenRC的timezone配置

然后重新配置 ``sys-libs/timezone-data`` 软件包，这个软件包会更新 ``/etc/localtime`` :

.. literalinclude:: install_gentoo_on_mbp/timezone-data
   :language: bash
   :caption: 重新配置 sys-libs/timezone-data

待续...
