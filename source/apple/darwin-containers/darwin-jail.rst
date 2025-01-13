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

由于第一次在本地主机上制作 ``darwin-jail`` 并不顺利，制作出来超大占用空间，并且没有普通用户目录(其实当时我不知道 ``chroot`` 可以指定用户身份)，所以我第二次做了准备工作: 使用 :ref:`vmware_fusion` 安装了一个干净的 macOS 系统。

- 完成 :ref:`vmware_macos_init`

部署和使用
=============

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
