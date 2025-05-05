.. _homebrew_formulae:

=============================
Homebrew Formulae(公式)
=============================

``Homebrew Formulae`` 是一种Homebrew所使用的在线package browser，也就是软件包管理器。实际上每个Formulae(公式)就是指导Homebrew如何安装软件包的一个 :ref:`ruby` 代码文件

有时候，如果官方Formulae存在问题没有及时更新，可以通过单独下载Formulae文件进行修订，离线安装。本文是一些实践案例

.. _homebrew_openssl:

Homebrew 安装 openssl
=============================

在 :ref:`homebrew_init` 中安装 :ref:`colima` ，对于早期旧版本 macOS 11，存在一个问题是，当安装 :ref:`qemu` 需要编译安装 openssl 3.5.0。但是旧操作系统环境，在编译安装 openssl 3.5.0 的test阶段会出现部分失败。这就导致自动安装过程中断，提示报错:

.. literalinclude:: homebrew_formulae/test_fail
   :caption: homebrew安装openssl报错

解决方法是手工安装 OpenSSL ，需要先下载 Homebrew的 formula，然后修订这个formula文件，移除 ``system "make", "test"`` 行，在编译安装

.. literalinclude:: homebrew_formulae/install_openssl
   :caption: 手工安装openssl

.. _homebrew_snappy:

Hoebrew 安装 snappy
=======================

snappy是Google开发的一个压缩和解压库，不追求最大压缩率，但是专注于高速和明确的压缩。2025年5月，我在 :ref:`mbp15_late_2013` 上使用 :ref:`macos` Big Sur version 11.7.10，这个比较陈旧的macOS系统安装 :ref:`colima` 遇到一个依赖安装问题:

``brew install qemu`` 报告 ``cmake`` 版本过低问题:

.. literalinclude:: homebrew_formulae/cmake_err
   :caption: 现实cmake版本过低报错

但是，我检查 homebrew 实际上已经安装了 ``/usr/loca/bin/cmake`` 版本是 4.0.1

这个问题有点类似 `VDT Configuration Errors (Mac OS 15.4) <https://root-forum.cern.ch/t/vdt-configuration-errors-mac-os-15-4/63330>`_ ，似乎有多个项目兼容cmake 4.0有问题。果然，在snappy的github项目上，已经有人提出了issue: `Require Update to CMakeLists.txt for source build due to new CMake 4.0(+) requirements #204 <https://github.com/google/snappy/issues/204>`_ ，这个修复是在 snappy 1.2.2 ，但是目前 `homebrew-core/snappy 1.2.2 #216761 <https://github.com/Homebrew/homebrew-core/pull/216761>`_ 还阻塞没有合并，所以当前安装的是 snappy 1.2.1 存在这个报错

可以参考 `Homebrew Formulae: snappy <https://formulae.brew.sh/formula/snappy>`_ 当前确实是 1.2.1 版本( snappy 官方 1.2.2 是3月26日发布，我当前在5月2日安装可以看到homebrew还停留在1.2.1)

.. literalinclude:: homebrew_formulae/install_snappy
   :caption: 手工安装snappy

.. _homebrew_qemu:

Homebrew 安装qemu
====================

在旧版本macOS Big Sur上安装 ``qemu`` 除了遇到上述openssl和snappy的formulae的异常之外，还有一个对编译器版本要求的报错:

.. literalinclude:: homebrew_formulae/gcc_error
   :caption: 编译qemu提示需要gcc或clang符合版本要求
   :emphasize-lines: 3

由于笔记本 :ref:`mbp15_late_2013` 硬件限制，只能安装Big Sur，也就导致Xcode clang版本停留在 13.0。我尝试通过 Homebrew 安装高版本gcc:

.. literalinclude:: homebrew_formulae/gcc
   :caption: 安装gcc 14.2

但是发现报错依旧，难道在macOS平台默认只能使用Clang来编译(即使我安装了符合要求的gcc版本)?可以看到configure时候制定了 ``--cc=clang --host-cc=clang``

仔细检查 ``qemu.rb`` 可以看到传递给 ``configure`` 的配置使用了 ``#{ENV.cc}`` ，正是这个参数导致默认用了clang，我需要将这个参数改成使用自己安装的高版本gcc

我尝试修订 ``qemu.rb`` ，将:

.. literalinclude:: homebrew_formulae/qemu_orig.rb
   :caption: 原本的 ``qemu.rb``

修改成

.. literalinclude:: homebrew_formulae/qemu.rb
   :caption: 修订 ``qemu.rb``

这样果然能够看到 ``./configure --cc=gcc --host-cc=gcc --disable-bsd-user ...`` ，但是报错依旧，似乎 ``meson.build`` 没有使用这个传递参数。

`MacPort: qemu @9.2.0_0: ERROR: Problem encountered: You either need GCC v7.4 or Clang v10.0 (or XCode Clang v15.0) to compile QEMU <https://trac.macports.org/ticket/71593>`_ 提到了 qemu 需要 macOS 12 or later

检查了 qemu 的issue `error: implicit declaration of function 'IOMainPort' is invalid in C99 <https://gitlab.com/qemu-project/qemu/-/issues/2694>`_ 官方只支持两个主要macOS版本:

  - Sonoma (14)
  - Sequoia (15)

`[PATCH] meson.build: Refuse XCode versions < v15.0 <https://lists.gnu.org/archive/html/qemu-devel/2024-11/msg04810.html>`_ 已经移除了旧版本macOS的支持

我尝试 :ref:`homebrew_old_qemu`

参考
======

- `Test failed in 3 with homebrew upgrade on macOS Catalina #21478 <https://github.com/openssl/openssl/discussions/21478>`_
