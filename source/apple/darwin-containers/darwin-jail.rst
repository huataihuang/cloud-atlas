.. _darwin-jail:

=======================
darwin-jail
=======================

``darwin-jail`` 是一个构建 Darwin chroot 目录的工具(jail)，可以抽取一个纯净的 ``jail`` 环境，以便能够在其中定制构建一些服务。这种jail环境是原生 macOS 系统，所以可以用来作为可移植的容器环境来使用，例如部署一些需要的工具和服务，并且一次部署，后续可以多次使用。

.. warning::

   实际构建的 ``darwinjail`` 环境还是比较占用空间的， Sequoia 15.2 上构建占用了 ``7.3G`` ( 我尝试在新安装虚拟机macOS中完成，但 ``darwinjail`` 只复制基础目录，确实占据了 ``7.3G`` )。

   还远远比不上 :ref:`freebsd_jail` 灵活的 :ref:`thin_jail` (基于 :ref:`zfs` 或 NullFS)。但是能够打包镜像，并且储备用于其他工作环境，还是比较有意思的。

准备工作
==========

- 完成 :ref:`vmware_macos_init`

- 完成 :ref:`homebrew_init` : 建议安装完 ``XCode command line tools`` 并完成所有 :ref:`homebrew` 需要的软件之后再制作 ``darwin-jail`` ，这样能够完整包含所需工具以及依赖库。

部署和使用
=============

- (这步我现在通过调整 ``darwin-jails`` 配置来完辰统一打包)建议先安装 XCode command line tools，然后打包  ``/Library/Developer/CommandLineTools`` 目录

这样不仅具备了 :ref:`clang` (gcc是clang的别名),也包含了 :ref:`swift` ，就不需要在 :ref:`homebrew` 中再安装llvm了 -  参考 `如何在 mac 电脑上轻量化地写C <https://zhuanlan.zhihu.com/p/58425193>`_

不过，在 ``darwin-jail`` 中执行 ``gcc --version`` 提示信息:

.. literalinclude:: darwin-jail/gcc_confstr_error
   :caption: ``gcc --version`` 提示信息提示错误

这个报错是因为 ``getconf DARWIN_USER_TEMP_DIR`` 就有提示错误  ``getconf: confstr: DARWIN_USER_TEMP_DIR: Input/output error``

我在正常的环境中执行上述命令，可以到哪看到 ``DARWIN_USER_TEMP_DIR`` 对应的目录 ``/var/folders/fb/1zwz4_152_g8lv6w4m6zq78r0000gn/T/`` ，实际上是因为在jail中无法写入 ``/var/folders`` 导致的报错

则在jail中也补上:

.. literalinclude:: darwin-jail/temp
   :caption: 为jail中用户补上tmp目录

- 执行:

.. literalinclude:: darwin-jail/darwinjail_chroot
   :caption: 下载代码并构建chroot

- 为了在chroot中能够使用DNS，执行:

.. literalinclude:: darwin-jail/darwinjail_dns
   :caption: 配置dns

.. note::

   ``chroot`` 目录中没有包含用户目录，也没有用户账号，所以需要 :ref:`macos_user_account_cmd` 创建(但是我目前执行创建错误 ``Operation failed with error: eParameterError`` 待排查)

   怎么搞定普通用户账号？没有普通用户账号，运行 :ref:`homebrew` 是个大问题:

   解决方法是使用 ``sudo chroot -u admin`` 来执行，这样进入chroot环境后就是指定用户 ``admin``

补充工作
-----------

- 将 :ref:`homebrew_init` 制作的 ``brew.tar.gz`` 复制到 jail 根目录下解压缩

- 配置 ``~/.zprofile`` :

.. literalinclude:: darwin-jail/zprofile
   :caption: ``~/.zprofile`` 添加 :ref:`homebrew` 路径，并过滤掉 ``df`` 命令无法获取的属性报错

- 配置 ``~/.gitconfig`` :

.. literalinclude:: darwin-jail/.gitconfig
   :caption: 配置git

- :strike:`由于jail无法访问外部数据，对于需要处理的数据目录需要存放到jail中，然后在外面建立一个软链接方便查看` 需要 :ref:`bindfs` 进行目录映射

- 需要进一步学习 :ref:`macos_apfs_cli`

一些限制和问题
================

- 无法在 ``chroot`` 环境中使用 :ref:`tmux` 和 ``screen`` : ``tmux`` 直接退出， ``screen`` 则提示错误 ``Must be connected to a terminal.``

参考 `How do I use the terminal SCREEN when chrooted? <https://superuser.com/questions/487013/how-do-i-use-the-terminal-screen-when-chrooted>`_ ，需要将 ``/dev/pts`` (pseudo-terminal文件系统 ``devpts`` 挂载到chroot内部。不过，方法是针对Linux的，我没有找到macOS下方法。

将Darwin rootfs作为Docker镜像
================================

- 安装 ``crane`` 工具制作镜像

.. literalinclude:: darwin-jail/crane
   :caption: 制作镜像

.. note::

   ``crane`` 是 `GitHub: google/go-containerregistry <https://github.com/google/go-containerregistry>`_ 中包含的一个工具.

   `A Tale of Two Container Image Tools: Skopeo and Crane <https://eng.d2iq.com/blog/a-tale-of-two-container-image-tools-skopeo-and-crane/>`_ 介绍了容器镜像工具

参考
=======

- `GitHub: darwin-containers/darwin-jail <https://github.com/darwin-containers/darwin-jail>`_
- `How to run a command in a chroot jail not as root and without sudo? <https://stackoverflow.com/questions/3737008/how-to-run-a-command-in-a-chroot-jail-not-as-root-and-without-sudo>`_
- `GitHub: keith/dyld-shared-cache-extractor <https://github.com/keith/dyld-shared-cache-extractor>`_ 解释了macOS使用 ``dyld-shared-cache`` 的背景
