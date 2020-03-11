.. _compare_container_os:

=================
容器操作系统比较
=================

由于Docker需要操作系统尽可能轻量级，并且docker容器仅仅使用部分内核功能，所以如果你使用容器作为微服务的运行架构，则使用完整功能的Linux操作系统是非常不经济并且带来更多的安全隐患。无用的服务和功能会消耗CPU和内存，并且加大了被攻击面。所以，涌现出一批裁剪Linux操作系统作为容器特定操作系统。

- :ref:`container_linux`

著名的CoreOS公司被Red Hat收购以后，CoreOS改名为为container linux。由于融入Red Hat构建的容器架构战略，替代了Red Hat原先开发的 :ref:`atomic` 成为 :ref:`openshift` 的运行基础，并且结合了CoreOS开发的 :ref:`kubernetes` 核心组件 :ref:`etcd` ，所以我觉得是良好发展前景的容器化Linux发行版。

- :ref:`chromium_os`
  - flint os: 基于 :ref:`chromium_os` 的二次开发
  - fydeos: 国内基于 :ref:`chromium_os` 的二次开发，有 `知乎上的FydeOS话题 <https://www.zhihu.com/org/fydeos>`_ 提供了借鉴，并提供 `itNT 72系列fydeos设备 <https://fydeos.com/itnt72>`_ 。

严格来说 chrome os并不是面向服务器领域的容器化Linux，但是开源的 :ref:`chromium_os` 精简Linux内核以及双分区无缝滚动升级特性被CoreOS吸收成为核心功能。并且现在chromebook设备运行的chrome os为了丰富功能，引入了 :ref:`archon` 运行Android应用，也引入了容器技术运行Linux发行版。

ChromeBook是我们可以购买到的较为成熟的商品化轻量级容器运行笔记本，并且兼顾Andorid运行。

.. note::

   ChromeBook Slate平板电脑二合一产品线(实际上是Chrome平板)作为失败产品已经被Google放弃，但是 `Pixelbook 2传言一直在开发 <https://www.digitaltrends.com/computing/pixelbook-go-news-rumors-specs-release-date/>`_ 。

- :ref:`atomic`

Red Hat开发多年的轻量级容器操作系统，并且组合了多种开源技术，例如 :ref:`cockpit` 。虽然已经被 :ref:`container_linux` 替代不再开发，但是其设计架构依然值得借鉴。

- :ref:`photon_os`

VMware开发的Photon OS是针对VMware Sphere，VMware Fusion等vmware系列的轻量级容器操作系统，并且可以迁移到公有云AWS，Azure上运行。可以认为是VMware私有云和公有云转换的利器：你可以在公司内部运行全套的VMware平台，测试、开发并且运行高度安全要求的应用，同时也能将部分公开计算迁移到公有云，此时使用Photon OS就能够起到统一平台的效果。

参考
======

- `5 Prominent Linux Container Specific Operating Systems <https://linoxide.com/containers/linux-container-operating-systems/>`_
