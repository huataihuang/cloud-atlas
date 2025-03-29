.. _introduce_anbox_cloud:

=======================
Anbox Cloud简介
=======================

:ref:`anbox` 提供了在Linux中构建Andorid运行环境，并且采用了轻量级容器技术，抽象了硬件加速和继承核心系统服务，可以兼容Android应用，并且提供了跨x86和ARM的运行支持。

随着云游戏的逐步发展(道路依旧坎坷)，以及轻量级 :ref:`chromium_os` (Chorme OS/Chrome Book设备) 发展，有一种技术发展方向是将大量的计算、渲染完全由数据中心完成，你可以使用一个浏览器接入，随时获得大量的计算和图形资源。

`Anbox Cloud anbox-cloud.io <https://anbox-cloud.io/>`_ 是Canonical (著名的 :ref:`ubuntu_linux` 发行公司) 推出的结合 Anbox 和 LXC (容器) 实现的一个rich software stack，可以在云上运行Andorid的解决方案。

Anbox Cloud类似方案
======================

:ref:`akraino` 也集成了类似的架构技术方案 `R3 Architecture Document of IEC Type 3: Android cloud native applications on Arm servers in edge <https://wiki.akraino.org/display/AK/R3+Architecture+Document+of+IEC+Type+3%3A+Android+cloud+native+applications+on+Arm+servers+in+edge>`_ ，这个方案是基于Kubernetes实现的边缘计算。



参考
=========

- `Anbox Cloud Overview <https://anbox-cloud.io/docs/overview>`_
