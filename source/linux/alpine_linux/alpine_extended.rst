.. _alpine_extended:

=====================
U盘运行Alpine Linux
=====================

我的运行模式
==============

我是在 MacBook Pro 15" 2013 late笔记本上使用Alpine Linux，采用外接U盘方式，所以我准备采用 ``diskless`` 模式。不过，内置的硬盘也不能浪费，原装SSD硬盘512G，虽然已经在macOS install过程中爆SMART错误，不过还能废物利用，我准备作为本地数据盘使用。

目前我对 :ref:`btrfs` 发展比较看好，所以会在内置磁盘上启用btrfs来构建一些虚拟机和容器的性能测试。不过，重要数据还是采用 :ref:`ceph` 和 :ref:`gluster` 分布式存储保存的到ARM集群运行的存储中。
