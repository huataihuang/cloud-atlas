.. _dell_r630:

=================
Dell R630服务器
=================

Dell R630服务器是Dell于2016年推出的1U机架式服务器，占用机架资源小同时又具备了当时主流服务器性能，适合小型企业和高密度部署通用服务器。

2021年在二手市场R630服务器的售价极为低廉，几乎就是一台普通台式机的售价，适合服务器技术爱好者练习和实验用途。

硬件配置
=============

PowerEdge R630:

- CPU: :ref:`xeon_e5-2600_v4` 版本
- 内存: 24 DIMMs DDR4，最高支持768GB
- 主板芯片: :ref:`intel_c610`
- 存储: 最高支持10个 2.5"驱动器，不过二手市场通常提供的是8个 2.5"插槽，可以配置8个2.5"笔记本用SSD磁盘来降低总体成本，同时拥有最大化的存储容量

架构设计
================

由于Intel处理器支持 :ref:`kvm_nested_virtual` ，可以在同一台物理服务器上:

- 通过第一层虚拟化，运行8~10个虚拟机，通过 PassThrough 直接访问存储，模拟裸机集群

  - 在第一层虚拟化直接访问存储的高性能架构上，实现分布式存储 :ref:`ceph` 和 :ref:`gluster` ，为整个虚拟化环境提供基础存储

- 通过第二层虚拟化，每个第一层虚拟机运行若干二层虚拟机，实现大规模 :ref:`openstack` 集群
- 在OpenStack运行的二层虚拟机中运行 :ref:`kubernetes` 以及其他分布式服务

操作系统选择:

- 在PowerEdge r630服务器的最底层Linux操作系统，我考虑采用 :ref:`lfs` 定制一个完全自制的精简操作系统，因为在这个层上除了精简的 :ref:`kvm` 没有任何软件运行需求，我们追求性能的极致，同时也磨练对 :ref:`kernel` 的技术
- 在第一层虚拟化层，运行模拟物理主机群的操作系统，选择 :ref:`ubuntu_linux` ，原因是 Ubuntu 提供了大量的应用软件stack，支持几乎所有商业和自由软件，可以方便运维管理 
- 在第二层虚拟化层，则百花齐放，将部署各种Linux操作系统，体验各种技术

参考
========

- `Poweredge R630 <https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/aa/Dell-PowerEdge-R630-Spec-Sheet.pdf>`_
