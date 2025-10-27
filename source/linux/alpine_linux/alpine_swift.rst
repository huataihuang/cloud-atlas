.. _alpine_swift:

=======================
Alpine Linux安装Swfit
=======================

概述
=======

.. note::

   本文方案我暂时没有实践，仅仅是我整理的可能方案以供今后参考。

目前来看，苹果的Swift是针对标准发行版glibc构建的Swift toolchain，这导致无法直接在Alpine Linux上运行。现有方案都是一种曲折的替代方案:

- 通过 ``debianbootstrap`` 来构建一个 ``chroot`` 环境，以便获得标准的 ``glibc`` 运行环境: 就像在一个 :ref:`docker` 中运行 :ref:`debian_tini_image` 标准Linux运行 :ref:`swift` 和 swift开发的程序
- Swift 6开始支持编译完全静态Linux二进制程序，这样就能够使用 ``musl`` 作为标准C库来运行Swift程序甚至Swift开发环境( 苹果提供了 `Swift SDK Bundles <https://www.swift.org/install/linux/#swift-sdk-bundles>`_ 实现静态二进制构建，详情参考 `Getting Started with the Static Linux SDK <https://www.swift.org/documentation/articles/static-linux-getting-started.html>`_ )

方案一实际上是容器化运行，所以真不如不要使用Alpine Linux，而采用在Alpine Linux Host主机上，采用 :ref:`docker` 来运行一个 :ref:`debian` 容器，在容器中来运行Swift开发环境和Swift开发的程序

方案二是苹果官方提供的跨平台方法，理论上是可行的，但是首先要从源代码编译Swift开发工具链，需要先安装 ``Linux Static SDK`` 来编译Swift。此外使用静态编译的Swift开发的程序，二进制包会急剧膨胀，原本动态连接库只需要几百K到1M的二进制执行程序，会增加到100+MB以上

我感觉除非苹果官方支持musl来构建Swift，否则通过变通方法在Alpine Linux上运行Swift程序意义不大，不如直接采用 :ref:`debian` 这样标准的linux发行版 :ref:`docker` 容器来运行。

参考
======

- `Packaging Swift apps for Alpine Linux <https://mko.re/blog/swift-alpine-packaging/>`_
