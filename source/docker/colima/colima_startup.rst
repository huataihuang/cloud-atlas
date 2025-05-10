.. _colima_startup:

=================
Colima快速起步
=================

安装
=========

.. note::

   colima 支持两种 :ref:`container_runtimes` :

   - :ref:`docker` : 通过 ``colima start`` 启动如果没有带 ``运行时`` 参数，则默认等同于 ``colima start docker`` ，此时要求系统已经通过 ``brew install docker`` 安装过 :ref:`docker_desktop` ，否则报错`
   - :ref:`containerd` : 通过 ``colima start containerd`` 启动则会通过 :ref:`lima` 运行一个 :ref:`ubuntu_linux` 虚拟机来运行 :ref:`containerd`

- 通过 :ref:`homebrew` 安装 ``colima`` :

.. literalinclude:: colima_startup/brew_install_colima
   :caption: 在 :ref:`macos` 平台安装colima

可以看到同时依赖安装了如下组件::

   capstone, dtc, libslirp, libssh, libusb, vde, qemu and lima

.. note::

   :ref:`qemu` 目前(2025年)官方最新版本 ``qemu-10`` 仅支持macOS 14和15，在旧版本 macOS Big Sur上无法完成安装。我最终折腾很久才完成 :ref:`homebrew_old_qemu` 部署。

   旧版macOS Big Sur不支持 ``vz`` 类型，所以必须安装 :ref:`qemu` ，而且旧版homebrew不会自动以来安装qemu，需要单独完成 :ref:`homebrew_old_qemu` 部署。

- 根据安装提示，使用如下命令启动 ``colima`` 服务:

.. literalinclude:: colima_startup/brew_start_colima
   :caption: 在 :ref:`macos` 平台通过 ``brew services`` 命令启动 ``colima`` 服务

.. note::

   ``brew services start colima`` 是在后台作为服务自动启动Colima，如果要在前台运行，可以直接使用 ``colima start`` 命令，例如:

   .. literalinclude:: colima_startup/colima_foreground
      :caption: 前台运行 ``colima`` 服务

使用
=====

- ``colima start`` 是启动一个 :ref:`container_runtimes` 的Linux虚拟机，不带任何参数就默认使用 :ref:`docker` ，此时要求系统已经 :ref:`homebrew` 安装过 :ref:`docker_desktop`

- 我为了能够适应当前 :ref:`kubernetes` 的只部署 :ref:`containerd` 运行时，没有完整的 :ref:`docker` 组件，所以我使用的启动命令是:

.. literalinclude:: colima_startup/colima_start_containerd
   :caption: 使用 ``colima start`` 指定 :ref:`containerd` 作为运行时

此时输出显示 :ref:`lima` 启动一个 :ref:`ubuntu_linux` :ref:`arm` 版本虚拟机(因为我是在ARM架构的 :ref:`apple_silicon_m1_pro` Macbook Pro上):

.. literalinclude:: colima_startup/colima_start_containerd_output
   :caption: 输出显示启动ARM版本的 :ref:`ubuntu_linux`

此时会从GitHub上下载对应架构的虚拟机镜像以及UEFI代码，如果 :strike:`一切顺利` ... ，显然对于墙内用户是有点折腾的。

.. note::

   这里有一个麻烦是GFW对GitHub访问干扰非常严重，往往难以完成下载。我的解决方法是:

   - 先部署 :ref:`squid_socks_peer` 构建跨越长城的代理
   - 然后设置 :ref:`curl_proxy`

``colima start`` 选项
========================

运行 ``colima start help`` 命令可以看到，这个运行命令实际上有很多参数，提供了不同运行模式:

4c8g规格案例
--------------

- 我在 :ref:`mbp15_2018` 上构建一个使用 ``vz`` 模式的 ``4c8g`` 虚拟机运行 ``colima`` :

.. literalinclude:: colima_startup/colima_vz_4c8g
   :caption: 使用 ``vz`` 模式虚拟化的 ``4c8g`` 虚拟机运行 ``colima``

- 启动后检查运行的虚拟机:

.. literalinclude:: colima_startup/colima_list
   :caption: 执行 ``colima list`` 可以看到运行的虚拟机

显示刚才启动的 ``4c8g`` 虚拟机:

.. literalinclude:: colima_startup/colima_list_output
   :caption: 显示 ``4c8g`` 虚拟机

- 如果需要修订 :ref:`colima_storage_manage` ，则配置修订后需要重启 ``colima`` 虚拟机:

.. literalinclude:: colima_startup/colima_restart
   :caption: 重启 colima 虚拟机

2c4g规格案例
--------------

- 我在 :ref:`mbp15_late_2013` 上使用的是旧版本macOS Big Sur，也就是macOS 11，这种低版本intel架构macOS提示不支持 ``--vm-type=vz`` ，所以实际上是以 :ref:`qemu` 方式运行

.. literalinclude:: colima_startup/colima_qemu_2c4g
   :caption: 使用 ``qemu`` 模式虚拟化的 ``2c4g`` 虚拟机运行 ``colima``

.. note::

   根据 :ref:`lima` 官方文档 `Lima VM types <https://lima-vm.io/docs/config/vmtype/>`_ 说明， ``VZ`` 选项( :ref:`apple_virtualization` )需要 ``macOS >= 13.0`` (Lima >= 0.14)

多个docker虚拟机运行案例
--------------------------

如果没有指定 ``-p`` 或 ``--profile`` 指定配置名，那么会使用 ``default`` 作为实例的名字，也即是上文启动命令启动的名为 ``default`` 虚拟机。如果需要启动多个docker虚拟机，则需要通过参数完成::

   -p, --profile string   profile name, for multiple instances (default "default") 

以下是启动一个名为 ``test`` 的 Colima 虚拟机(登陆到这个虚拟机内部则会看到虚拟机主机名是 ``colima-test`` ):

.. literalinclude:: colima_startup/start_test
   :caption: 启动一个名为 ``test`` 的虚拟机实例

对应登陆这个虚拟机的时候也需要使用 ``-p`` 或 ``--profile`` 指定配置名:

.. literalinclude:: colima_startup/ssh_test
   :caption: ssh进入 ``test`` 的虚拟机实例



``colima ssh``
==================

执行SSH可以登陆到 ``colima`` 虚拟机内部:

.. literalinclude:: colima_startup/colima_ssh
   :caption: 通过SSH登陆到colima虚拟机内部

清理colima
==============

如果不再需要 ``colima`` ，可以 ``delete`` 掉虚拟机:

.. literalinclude:: colima_startup/colima_delete
   :caption: 执行 ``colima delete`` 删除不需要的colima虚拟机(所有数据丢失!!!)

此时会提示信息警告，确认 ``y`` 之后删除:

.. literalinclude:: colima_startup/colima_delete_output
   :caption: 执行 ``colima delete`` 删除提示警告数据完全删除

这个删除会清理掉用户 ``~/.colima/`` 目录下对应的虚拟机配置以及该目录下 ``ssh_config`` 证书配置。当再次创建colima会重新生成配置

``colima nerdctl``
====================

既然我安装的是 :ref:`containerd` 运行时，那么就需要配套的 :ref:`nerdctl` 交互。通过以下方式安装 ``nerdctl`` alias (实际上是一行脚本) 到 ``$PATH`` 就可以使用 ``colima nerdctl`` 子命令进行交互( 非常类似 :ref:`kubectl-plugins` )，也可以直接使用 ``nerdctl``

.. literalinclude:: colima_startup/colima_install_nerdctl
   :caption: 通过 ``colima install`` 安装 :ref:`nerdctl`

:strike:`按照提示输入系统管理员用户密码后，` 就会安装一个脚本文件 ``/usr/local/bin/nerdctl`` ，这个脚本非常简单，就是 ``colima nerdctl`` 的一个包装:

.. literalinclude:: colima_startup/colima_nerdctl
   :language: bash
   :caption: ``/usr/local/bin/nerdctl``

这样我们就既可以使用 ``colima nerdctl`` 也可以直接使用 ``nerdctl`` 来和系统中安装运行在虚拟机中的 :ref:`containerd` 进行交互。当然，即使不执行 ``colima nerdctl install`` 其实也可以和Colima虚拟机中的 :ref:`containerd` 交互，就是一直使用 ``colima nerdctl`` ，安装的好处是方便了在Host主机上操作(简化了命令关键字)。

- 使用 ``nerdctl`` 检查:

.. literalinclude:: colima_startup/nerdctl_ps
   :caption: ``nerdctl`` 检查

此时，还没有任何运行容器，所以显示是空的

.. literalinclude:: colima_startup/nerdctl_ps_output
   :caption: ``nerdctl`` 检查此时还没有容器运行

接下来使用方法和 :ref:`docker_desktop` 相同，可以使用 :ref:`nerdctl` 来实现镜像的拉取、容器运行等操作

Colima配置概述
=================

Colima的配置可以通过 ``$COLIMA_HOME`` 设置特定的配置文件位置，否则默认就是 ``$HOME/.colima`` 

在 ``$HOME/.colima`` 目录下你可以找到

- ``ssh_config`` 配置文件，这个配置文件指定了如何登陆到 ``colima`` 虚拟机内部进行维护
- ``default`` 目录下保存了刚才我创建的虚拟机配置，

  - ``colima.yaml`` 就是创建虚拟机的配置，当再次执行 ``colima start`` 或 ``colima stop`` 就会读取这个配置文件启动或停止虚拟机，可以修改这个配置来更改虚拟机的设置 

``colima.yaml``
=================

``colima.yaml`` 提供了很多创建虚拟机的配置，并且提供了详细的注释，所以只要简单浏览一下就能够了解如何调整配置。以下是一些有用的配置

- :ref:`colima_storage_manage`

运行容器案例
============

通过 :ref:`docker_images` 定义，使用相同的方法，可以运行起不同的工作环境

异常和解决
===========

``lima`` 虚拟机文件和本地文件
---------------------------------

.. warning::

   这段错误应该是我自己搞错环境导致的，我现在回想起来当时自己定义了 :ref:`colima_storage_manage` ，没有默认挂载当前用户的 ``$HOME`` 目录，导致Colima虚拟机内部路径和Host主机不一致。如果没有修改默认存储挂在，或者确保定制存储挂载依然包含用户的 ``$HOME`` 目录，就不会有这个问题。

使用 ``containerd`` 作为 :ref:`containerd_runtime` ，我在执行 :ref:`gentoo_image` :

.. literalinclude:: colima_startup/build_gentoo-base_image
   :language: bash
   :caption: 采用 ``nerdctl build`` 构建基础Gentoo镜像Dockerfile

出现如下报错:

.. literalinclude:: colima_startup/build_gentoo-base_image_err
   :language: bash
   :caption: 采用 ``nerdctl build`` 构建基础Gentoo镜像出现的报错显示 ``lima`` 虚拟机中缺少对应文件

原因是执行 ``nerdctl`` 是在 :ref:`macos` 上，这个命令访问的运行 :ref:`containerd_runtime`  位于 :ref:`lima` 虚拟机中，当虚拟机目录和本地 :ref:`macos` 目录不是映射等同关系时，就会导致无法找到目录文件。

有没有办法将 :ref:`macos` 本地目录映射到虚拟机内部呢？

.. note::

   这个问题应该是 ``containerd`` 后端特有的，我以前使用 :ref:`docker_desktop` 就不存在这个异常，说明 :ref:`docker_desktop` 做了相应转换

   暂无时间排查，我目前主要是在 :ref:`gentoo_docker` 上完成，暂时绕过这个问题。等后面在 :ref:`macos` 上工作时再解决

参考
========

- `GitHub: abiosoft/colima <https://github.com/abiosoft/colima>`_
- `Replace Docker-Desktop in Mac with Lima-VM, nerdctl and containerd <https://techexpertise.medium.com/replace-docker-desktop-in-mac-with-lima-vm-nerdctl-and-containerd-4a0cdc36d9ec>`_
- `How do I completely remove the VM that colima uses on MacOS? #258 <https://github.com/abiosoft/colima/issues/258>`_
