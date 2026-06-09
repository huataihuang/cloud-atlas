.. _intro_lxd:

=================
LXD简介
=================

我在很久以前，还在支付宝、淘宝做运维的时候，当时淘系的容器系统是基于LXC构建的T4系统。那时LXC还是比较原始的阶段，需要拼凑网络和cgroup等管理，构建一个从host主机剥离出来的操作系统。

随着 :ref:`docker` 的崛起，容器化的风潮兴起，业界也开始万物皆容器，Docker似乎势不可挡地取代了简陋(洁)的LXC，甚至到 :ref:`kubernetes` 横扫基础架构之后，似乎都遗忘了曾经最早提出cgroup隔离容器化运行的LXC技术。

然而，Docker的一切以轻量化应用为中心的运行理念，也对部分持久化、稳定性极高且深度绑定 :ref:`systemd` 的系统级"全能"容器带来了困难。在Docker中出于安全和轻量级的限制，使得运行systemd极其痛苦和麻烦，也带来底层服务的改造折腾。

这时，基于LXC构建的LXD容器，为这种系统级底层服务开启了一条新的道路:

- LXD能够同时管理容器和虚拟机，并且提供了运行和管理 **"完整"** Linux系统的一致体验
- 支持大量的Linux发行版并且内建了强大且简洁的REST API提供管理
- 可以在单机部署也可以在数据中心大量服务器上完成集群构建

我在之前的 :ref:`kubernetes` 集群模拟都是采用 :ref:`kvm` ，甚至尝试过采用 :ref:`kvm_nested_virtual` 来模拟构建 :ref:`openstack` 集群。但是，虚拟化对Host主机的资源消耗较大，对于我的HomeLab环境，每一分硬件都希望能够用于真正的业务上。我之前就考虑过采用 :ref:`kind` 来模拟 :ref:`kubernetes` 集群，但是特殊的简化版本定制使得HomeLab模拟削弱，所以我现在更考虑采用LXD来构建底座，实现一种轻量级的Node节点模拟。

LXD作为现代、安全且功能强大的系统容器和虚拟机管吸气，在容器或虚拟机中运行和管理完整的Linux系统提供了统一的体验。LXD支持众多Linux发行版景象，并且基于功能强大且简洁易用的REST API构建。这样LXD的规模可以从单机的单个实例扩展到整个数据中心的集群。

需要注意，在Ubuntu 24.04上，如果想要使用 **官方原生的LXD** 则必须使用 ``snap`` 。因为Canonical（Ubuntu 母公司）多年前就已经从 APT 官方源中彻底移除了 LXD 的 ``.deb`` 包，只提供 ``snap install lxd`` 这一种官方分发途径。

不过，对于习惯了传统 Linux 包管理、追求系统轻量化，并且我计划在宿主机上模拟 :ref:`kubernetes` ，Snap会带来一些不必要的麻烦(如：宿主机上多出大量挂载点、不可控的后台全自动更新导致 K8s 节点网络断开、以及路径嵌套过深等问题)。

所以，我的实践改为采用 :ref:`incus` 完成

.. note::

   由于 Canonical 在 2023 年底决定将 LXD 变更为完全闭门自营的项目，并更改了许可证，LXD 的原核心开发团队（包括其创始人 Stéphane Graber 以及 Linux Containers 开源社区）集体出走，共同创建了 LXD 的完全开源、由社区驱动的分支（Fork）—— Incus。

参考
=======

- `LXD documentation <https://documentation.ubuntu.com/lxd/latest/>`_
