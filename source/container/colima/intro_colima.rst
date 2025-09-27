.. _intro_colima:

==================
Colima简介
==================

.. figure:: ../../_static/container/colima/colima.png

   Colima - container runtimes on macOS (and Linux) with minimal setup.

Colima 意思是 Containers in :ref:`lima` ，目标类似Lima (在Mac上运行Linux) ，Colima项目的目标是在Mac上的Linux中运行容器。也就是类似 :ref:`docker_desktop` 。

Docker公司在2021年8月31日宣布的 `Docker Subscription Service Agreement <https://www.docker.com/legal/docker-subscription-service-agreement/>`_ 实际上已经禁止大型公司专业使用(原文大致的意思是只能个人使用、教育使用、非商业开源使用以及小型企业环境使用)。所以大型公司实际上不能将 Docker Desktop 用于公司内部的开发项目。

Colima是一个相对比较成熟的开源项目，在 `ThoughtWorks第29期技术雷达 <https://www.thoughtworks.com/content/dam/thoughtworks/documents/radar/2023/09/tr_technology_radar_vol_29_cn.pdf>`_ 被列为 **采纳** 平台，可以为开发者提供与生产一致的开发测试环境。

Colima功能
=============

.. figure:: ../../_static/container/colima/colima.gif

- 支持Intel和 Apple Silicion 架构Mac
- 简单的CLI接口
- 支持Docker和Containerd运行时
- 端口转发
- 卷挂载
- :ref:`kubernetes`
- 多个实例运行

本质上， ``colima`` 就是 **定制化** 的提供 :ref:`nerdctl` 的 :ref:`lima` 虚拟机，类似的产品还有 :ref:`rancher_desktop`

参考
======

- `GitHub: abiosoft/colima <https://github.com/abiosoft/colima>`_
