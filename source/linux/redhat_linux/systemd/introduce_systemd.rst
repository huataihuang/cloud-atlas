.. _introduce_systemd:

===================
systemd简介
===================

``Systemd`` 是Linux操作系统的系统和服务器管理器。它被设计成向后兼容 ``SysV`` init脚本，并提供了一系列的诸如并行启动服务，按需激活服务，系统状态快照，或者依赖的底层服务控制逻辑等功能。在Red Hat Enterprise Linux 7中，systemd替代了以前默认使用的 ``init`` 系统。

Systemd引入了 ``systemd units`` 概念，这些通过位于目录中的单元配置文件表述并包装了有关系统服务，监听套接字，保存的系统状态快照，以及有关init系统的其他对象的信息。完整的systemd单元类型参考下表 

- 可用的systemd单元类型

============================= =============== ==================================
单元类型                      文件扩展        描述 
============================= =============== ==================================
服务单元(Service unit)        ``.service``    系统服务
目标单元(Target unit)         ``.target``     systemd单元的组
自动挂载单元(Automount unit)  ``.automount``  文件系统自动挂载点
设备单元(Device unit)         ``.device``     通过内核识别的一个设备文件
挂载单元(Mount unit)          ``.mount``      一个文件系统的挂载点
路径单元(Path unit)           ``.path``       在一个文件系统中的一个文件或者目录
范围单元(scope unit)          ``.scope``      一个外部创建的进程
切片单元(Slice unit)          ``.slice``      管理系统进程的层次化组织的单元组
快照单元(Snapshot unit)       ``.snapshot``   systemd管理器的一个保存的状态
套接字单元(Socket unit)       ``.socket``     一个进程间通讯的套接字
交换单元(Swap unit)           ``.swap``       一个交换设备或者交换文件
计时器单元(Timer unit)        ``.timer``      一个systemd计时器
============================= =============== ==================================

- Systemd Unit位置

============================= ==============================================================================
目录                          描述 
============================= ==============================================================================
``/usr/lib/systemd/system/``  使用RPM包安装的Systemd单元
``/run/systemd/system/``      运行时创建的Systemd单元。这个目录比安装系统服务单元目录的优先级高
``/etc/systemd/system/``      由系统管理员创建和管理的Systemd单元。这个目录比运行时创建的systemd单元优先级高
============================= ==============================================================================



参考
======

- `10.1. Introduction to systemd <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd#sect-Managing_Services_with_systemd-Introduction>`_
