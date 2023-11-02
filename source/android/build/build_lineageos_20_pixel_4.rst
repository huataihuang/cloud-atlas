.. _build_lineageos_20_pixel_4:

=======================================
为Pixel 4编译LineageOS 20(Android 13)
=======================================

准备工作
==========

- :ref:`android_build_env_ubuntu`

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

- 初始化android仓库以及获取源代码:

.. literalinclude:: build_lineageos_20_pixel_4/repo_sync
   :caption: 初始化android仓库以及获取源代码

这里我遇到一个提示:

.. literalinclude:: build_lineageos_20_pixel_4/repo_sync_err
   :caption: 初始化android仓库以及获取源代码

按照提示复制升级 ``repo`` ::

   cp /home/admin/android/lineage/.repo/repo/repo /home/admin/bin/repo

然后重新执行仓库同步::

   repo init -u https://github.com/LineageOS/android.git -b lineage-20.0

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

   LineageOS 建议使用默认配置，不过我发现由于翻墙网络非常缓慢，适当增加同步并发可以加快同步。例如 ``repo sync -j 40`` (按照服务器的cpu core数量调整)

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

参考
======

- `Build LineageOS for Google Pixel 4 <https://wiki.lineageos.org/devices/flame/build>`_
- `How to build LineageOS inside a container <https://dzx.fr/blog/how-to-build-lineageos-inside-a-container/>`_
