.. _build_lineageos_21_chromecast_tv:

==========================================================
为Chromecast with Google TV编译LineageOS 21(Android 14)
==========================================================

.. note::

   LineageOS 21(Android 14)支持 :ref:`chromecast_tv` ，可以自己完成精简编译，所以我准备折腾一下

   在原有 :ref:`build_lineageos_20_pixel_4` 基础上进行实践。本文待完成(在没有看到这段注释取消之前，表明实践尚未完成，则请勿参考本文)

准备工作
==========

- :ref:`android_build_env_ubuntu`

- 执行更新:

.. literalinclude:: android_build_env_ubuntu/apt_update_upgrade
   :caption: 修改仓库配置后更新和升级

- 安装LineageOS编译依赖:

.. literalinclude:: android_build_env_ubuntu/apt_intsall_build_dependencies_container
   :language: bash
   :caption: 在容器中安装Ubuntu编译LineageOS需要的依赖软件包

- 添加一个普通用户账号，注意这里关闭了密码:

.. literalinclude:: android_build_env_ubuntu/adduser_admin
   :caption: 添加一个 ``admin`` 账号并切换到这个账号

- 设置缓存 50G 并且在 ``admin`` 账号配置中启动 ``ccache`` :

.. literalinclude:: android_build_env_ubuntu/ccache
   :caption: 启用 ``ccache``

.. note::

   编译LineageOS需要惊人的磁盘空间，按照官方文档参考，linage-18.1就需要300GB空间，更高版本要求的空间更多...

   我的实践(LineageOS 20.0/Android 13):

   - ``repo sync`` 仓库同步占用 ``146G``
   - ``breakfast flame`` 后仓库占用 ``150G`` ( ``tar cfz`` 压缩以后大小 ``97G`` )

安装仓库
==========

- 创建目录并下载安装仓库:

.. literalinclude:: build_lineageos_20_pixel_4/repo
   :caption: 创建repo

- 配置 ``~/bin`` 到执行目录(添加到 ``~/.profile`` )

.. literalinclude:: build_lineageos_20_pixel_4/profile
   :caption: 将repo的 ``~/bin`` 路径添加到 ``~/.profile``

- 配置 ``git`` :

.. literalinclude:: build_lineageos_20_pixel_4/git
   :caption: 配置git

- **重要步骤** 安装 :ref:`git-lfs` :

.. literalinclude:: ../../devops/git/git-lfs/apt_install_git-lfs
   :caption: 在Ubuntu上安装git-lfs

- 在用户目录下执行 ``git-lfs`` 初始化:

.. literalinclude:: ../../devops/git/git-lfs/git_lfs_install
   :caption: 每个使用 ``Git Large File Storage`` 的用户账号下需要执行 git lfs 初始化

- 初始化android仓库以及获取源代码:

.. literalinclude:: build_lineageos_20_pixel_4/repo_sync
   :caption: 初始化android仓库以及获取源代码

.. note::

   访问GitHub仓库可能受到GFW干扰，所以需要采用:

   - :ref:`git_proxy`
   - :ref:`curl_proxy`

   不过，我实践还是遇到一个困难 :ref:`git_proxy` 使用HTTP/HTTPS代理时需要使用 :ref:`git-openssl` 来解决 :ref:`squid_socks_peer` 出现的TLS连接报错:

   .. literalinclude:: ../../devops/git/git-openssl/git_tls_connection_err
      :caption: git HTTPS代理访问 ``googlesource`` 报错 TLS连接中断
      :emphasize-lines: 4

   采用 :ref:`git-openssl` 解决

   此外，使用 OpenSSL 的 :ref:`curl` 也需要重新编译最新版本 :ref:`compile_curl_ssl` ，以便解决OpenSSL 3.0.x 的 ``unexpected EOF`` 报错

.. warning::

   **我最后放弃了通过代理翻墙方式来同步仓库** 原因是 ``实在难以找到合适的能够在墙内畅通访问的VPS`` (真是非常非常恶劣的网络环境)

   实际采用的方式是直接在墙外租用一个小型VPS进行源代码同步，然后通过 :ref:`rsync` 同步到墙内高性能服务器上进行编译(或许可以部署一个持续集成环境?)

.. note::

   ``repo sync`` 同步命令默认参数是 ``-j 4 -c`` 表示:

   - ``-j 4`` 表示并发4个同步线程(连接)
   - ``-c`` 表示 ``repo`` 值同步当前分支而不是GitHub上该仓库的所有分支

   LineageOS 建议使用默认配置，不过我发现由于翻墙网络非常缓慢，适当增加同步并发可以加快同步。例如 ``repo sync -j 12`` (按照服务器的cpu core数量调整)

- 准备设备特定代码:

.. note::

   这里针对 :ref:`pixel_4` 设备编译源代码，对应的code名字是 ``flame``

.. literalinclude:: build_lineageos_20_pixel_4/breakfast
   :caption: 同步设备特定代码

上述步骤会下载设备特定的配置文件以及内核

提取专有blobs
===============

如果你已经在设备中安装了LineageOS，就可以从设备中提取blobs。这个工作由 ``Android platform tools`` ( :ref:`adb` )完成，执行以下命令:

.. literalinclude:: build_lineageos_20_pixel_4/extract_proprietary_blobs
   :caption: 获取设备特定的专有blobs

此时会在 ``~/android/lineage/vendor/google`` 找到提取出来的 blobs

**我实际采用的方法** 是: :ref:`extract_proprietary_blobs_from_lineageos_zip` ，完成后在 ``~/android/lineage/vendor/google`` 就存放了 blobs 文件

.. warning::

   我这里也遇到了官方文档所说的 "部分设备需要一个vender(供应商)目录，然后才能 ``breakfast`` 成功。也就是说遇到类似如下的 ``makefile`` 错误，则需要从 **最新的LineageOS设备** 中提取响应的第一份专有blobs，然后才能完成 ``breakfast`` " :

   .. literalinclude:: build_lineageos_20_pixel_4/breakfast_err
      :caption: 执行 ``breakfast flame`` 错误信息

   这里有一个悖论，我没有这样已经安装过LineageOS的设备，如果有的话，则连接手机设备执行:

   .. literalinclude:: build_lineageos_20_pixel_4/extract_proprietary_blobs
      :caption: 获取设备特定的专有blobs

   实际上我是从官方网站下载这个对应 blobs ，也就是 `Install LineageOS on Google Pixel 4 <https://wiki.lineageos.org/devices/flame/install>`_ 官方下载 `LineageOS installation package <https://download.lineageos.org/devices/flame/builds>`_ 

   采用 :ref:`extract_proprietary_blobs_from_lineageos_zip` 提取 blobs

**然后再次执行** :

.. literalinclude:: build_lineageos_20_pixel_4/breakfast
   :caption: 同步设备特定代码

编译
========

- 终于到了最后一步:

.. literalinclude:: build_lineageos_20_pixel_4/build
   :caption: 编译

- 完成编译后，在 ``$OUTPUT`` 目录下(执行 ``cd $OUTPUT`` 到达该目录)会有如下编译后生成文件:

.. literalinclude:: build_lineageos_20_pixel_4/build_output
   :caption: 编译生成的文件

在 :ref:`hpe_dl360_gen9` 服务器上编译完成时间大约是 1小时50分::

   [100% 164133/164133] build bacon
   Package Complete: out/target/product/flame/lineage-20.0-20231103-UNOFFICIAL-flame.zip

   #### build completed successfully (01:49:31 (hh:mm:ss)) ####

可以开始 :ref:`lineageos_20_pixel_4`

编译问题排查
=============

``depmod`` 报错
------------------

- 首先遇到的是 ``depmod`` 报错:

.. literalinclude:: build_lineageos_20_pixel_4/build_depmod_err
   :caption: 编译过程出现无法找到 modules 的 ``depmod`` 报错

这个问题的解决方法我没有google到，不过我发现是我忽略了 `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_ 的一句话导致的:

If you receive an error here about vendor makefiles, jump down to Extract proprietary blobs. The first portion of breakfast should have succeeded, and **after completing you can rerun breakfast**

也就是我在首次执行 ``brekafast flame`` 来获取设备特定代码时失败(因为没有blobs)，所以我转为采用 :ref:`extract_proprietary_blobs_from_lineageos_zip` 完成 blobs 提取。这个步骤完成后，我只执行了 ``source build/envsetup.sh`` 但是没有重新执行 ``breakfast flame`` 就会出现上述报错。

``webview.apk: Invalid file`` 报错
--------------------------------------

再次编译遇到错误:

.. literalinclude:: build_lineageos_20_pixel_4/webview.apk_invalid_file
   :caption: ``webview.apk: Invalid file``
   :emphasize-lines: 5

我检查了一下 ``external/chromium-webview/prebuilt/arm64/webview.apk`` ，发现这个文件是一个ASCII文件:

.. literalinclude:: build_lineageos_20_pixel_4/webview.apk
   :caption: ``webview.apk``
   :emphasize-lines: 1

但是我关注到这个文件中的版本 ``git-lfs`` 似乎是官方文档中提到的需要支持 ``--git-lfs``

这是因为我最初不知道必须支持 :ref:`git-lfs` (默认系统没有安装 ``git-lfs`` 软件包，所以 ``git lfs install`` 初始化命令是报错的)，在初始化仓库使用去除了 ``--git-lfs`` 导致了这个后续仓库同步问题。

重新安装了 :ref:`git-lfs` 并重新同步仓库来完成

参考
======

- `Build LineageOS for Google Chromecast with Google TV (4K) <https://wiki.lineageos.org/devices/sabrina/build/>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
- `Android源码的下载，编译，刷机 <https://juejin.cn/post/7172004153453969415>`_ 国内通过AOSP是非常困难的，可以采用中国科大或者清华大学开源镜像来完成，具体可以参考 `清华大学开源软件镜像站: Android 镜像使用帮助 <https://mirrors.tuna.tsinghua.edu.cn/help/AOSP/>`_
