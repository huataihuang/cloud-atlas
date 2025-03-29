.. _think_gentooserv:

========================
Gentoo服务(器)思考
========================

我曾经多次 :ref:`install_gentoo_on_mbp` ，想要构建一个个人使用的非常轻量级的开发工作环境。然而，这并不是一个轻松的事情。至少对我而言，处理各种桌面应用的复杂编译和依赖，往往要耗费几天甚至几周的时间。

前一段时间，我在洗澡的时候，突然想到很久以前 :ref:`priv_cloud_infra` 我也构想过在最底层使用 :ref:`gentoo_linux` 甚至 :ref:`lfs` 来实现精简且性能最优的底层。既然我花费了这么多时间，仅仅为了桌面中文输入和 :ref:`sway` 这样轻量级的图形管理器，不如把时间投入到更为专注的服务器领域，将 :ref:`linux_server` +  :ref:`kubernetes` 和 :ref:`kvm` 结合实现 :ref:`performance` 的最优化。

构想
======

- 我有海量的服务器，而且只有我一个人(这是我撰写这本Cloud Atlas的初心)
- 实现无人值守的自动化Gentoo Linux 编译和定制

  - 自动编排汇总成数据中性所有机型列表: 由于Gentoo Linux的优势在于针对每个不同硬件和场景的定制，所以通过排列组合对集群服务器的硬件规格进行归类定制

    - 应该有工具能够处理硬件来找到对应的驱动，以便自动开启不同的编译开关
    - 在自动化基础上进行人工review，实现对模版的定制

  - 通过分布式编译网络( ``makermesh`` )来实现每个机型的自动编译(指定功能模版) => 定制内核以及 @world

    - 如果每个服务器都自我编译，那么耗时和异常之多肯定是一个人无法承受的，所以采用模版方式来编译完成一个定制的二进制Gentoo发行版来实现后续同机型同用途的服务器自动安装
    - 通过 ``discc`` 的Cross-Compiling，来实现跨架构的编译，支持 x86 和 :ref:`arm` 异构体系

技术构想
===========

虽然自己编写脚本也能做到降低重复劳动，包括现在Gentoo Linux安装也是包含很多命令，直接包装成脚本难度不大。

但是，考虑到工作场景复杂性以及最终需要实现海量服务器的横向扩展，所以我想基于通用的配置管理工具来实现，例如 :ref:`ansible` 。这样通过抽象和成熟的编排系统，更适合大规模部署业务场景。

.. note::

   我更希望通过这个实践来对业界成熟的配置管理工具进行深入研究，并实现更为适合Gentoo Linux自动部署模式。

一些参考
----------

我尝试google一下是否有和我类似的开源构建项目，不过可能还是我见识不广(英语表达不足)，我难以找到合适的参考项目。

有一些可能参考:

- `ansible-gentoo <https://github.com/jameskyle/ansible-gentoo>`_ 比较接近我的技术想法的 :ref:`ansible` 编排，可以作为起步参考。作者还写了一篇介绍文章 `Automated Stage3 Gentoo Install Using Ansible <https://blog.jameskyle.org/2014/08/automated-stage3-gentoo-install-using-ansible/>`_
- `install-gentoo <https://github.com/alexhaydock/install-gentoo>`_ 采用 :ref:`ansible` 在虚拟机环境构建gentoo，也是我想模拟的构建方案，而且项目比较接近近期(2021年)，很值得学习
- `Ansible role: Gentoo_install <https://github.com/agaffney/ansible-gentoo_install>`_ 比较古老的项目(7年前)，采用 :ref:`ansible` role完成安装

使用Shell实现:

- `Automated modular GENTOO linux setup <https://github.com/alphaaurigae/gentoo_unattented-setup>`_ 依然在活跃开发的自动完成Gentoo Desktop安装的脚本集合
