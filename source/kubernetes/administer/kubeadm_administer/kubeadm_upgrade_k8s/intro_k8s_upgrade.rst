.. _intro_k8s_upgrade:

=====================
Kubernetes升级简介
=====================

通过 :ref:`kubeadm` 创建的Kubernetes集群同样可以使用 ``kubeadm`` 进行升级，实践案例请见 :ref:`kubeadm_upgrade_k8s_1.25` ，本文为指导概述。

Kubernetes版本号
==================

- Kubernetes版本表示为 ``x.y.z`` ，其中x是主要版本，y是次要版本，z是补丁版本
- kubernetes项目存在3类分支(branch): 分别为master，release-X.Y,release-X.Y.Z

  - master分支上的代码是最新的，每隔2周会生成一个发布版本(release)，由新到旧以此为 ``master-->alpha-->beta-->Final release``
  - 一般认为 ``X.Y.0`` 为稳定的版本，这个版本号意味着一个 Final release; 一个 ``X.Y.0`` 版本会在 ``X.(Y-1).0`` 版本的3到4个月后出现
  - ``X.Y.Z`` 为经过cherrypick后解决了必须的安全性漏洞、以及影响大量用户的无法解决的问题的补丁版本

每个版本的支持时期
-------------------

- 每个主要版本的维护周期约为1年
- 每个次要版本的维护周期约为 9~12 个月

新版本对调用api的影响
-----------------------

kubernetes api在设计时遵循向上和/或向下兼容的原则:

- k8s的api是一个api的集合，称之为"API groups"
- 每一个API group维护着3个主要版本，分别是GA，Beta，Alpha

  - GA版本在宣告启用后将会向下兼容12个月或3个发行版
  - Beta版本则为9个月或3个发行版
  - lpha则会立刻启用

- **遵循kubernetes版本的升级规则** : 整体而言集群升级不支持跨度在2个Final release发行版之上的操作

  - 在 ``高可用性(HA)集群`` ( :ref:`bootstrap_kubernetes_ha` ) 最新版和最老版的 ``kube-apiserver`` 实例版本偏差最多为一个次要版本: 例如最新 ``kube-apiserver`` 是 1.25 ，而其他 ``kube-apiserver`` 实例可以是 1.25 和 1.24 版本
  - ``kubelet`` 版本不能比 ``kube-apiserver`` 版本新，并且最多只能落后2个次要版本: 例如 ``kube-apiserver`` 是 1.25版本，则 ``kubelet`` 版本支持 1.25, 1.24, 1.23
  - ``kube-controller-manager`` , ``kube-scheduler`` 和 ``cloud-controller-manager`` 不能比与它们通讯的 ``kube-apiserver`` 实例新，它们应该与 ``kube-apiserver`` 次要版本相匹配，但可能最多旧一个次要版本(允许实时升级): 举例 ``kube-apiserver`` 是1.25, 则 ``kube-controller-manager`` , ``kube-scheduler`` 和 ``cloud-controller-manager`` 支持 1.25 和 1.24 版本
  - ``kubectl`` 在 ``kube-apiserver`` 的一个次要版本（较旧或较新）中支持: 举例 ``kube-apiserver`` 是1.25, ``kubectl`` 支持 1.26, 1.25, 1.24

支持的组件升级顺序
====================

**组件之间支持的版本偏差会影响必须升级组件的顺序**

作为一种可选方案，在准备升级时，Kubernetes 项目建议:

- 确保组件是当前次要版本的最新补丁版本
- 将组件升级到目标次要版本的最新补丁版本

例如，如果当前运行 1.24 ，则应该将组件先升级到最新的补丁版本 1.24.7 。然后，在升级到 1.25 的最新补丁版本 1.25.3 => :ref:`kubeadm_upgrade_k8s_1.25`

.. note::

   采用将运行集群先升级到最新补丁版本然后再升级到下一个主版本的最新补丁版本，这种方式有利于升级过程中尽可能多的回归和错误修复。

参考
=======

- `升级 kubeadm 集群 <https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/>`_
- `Kubernetes版本升级实践 <https://zhuanlan.zhihu.com/p/358338665>`_
- `Kubernetes版本偏差策略 <https://kubernetes.io/zh-cn/releases/version-skew-policy/>`_
