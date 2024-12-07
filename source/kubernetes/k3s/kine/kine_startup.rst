.. _kine_startup:

==================
Kine快速起步
==================

我在蚂蚁金服(支付宝)工作的时候，曾经有一段时间协助过公司一个开发小组部署公司自研的 :ref:`etcd` 中间转换层，目标是将常规的etcd API调用通过中间层翻译存储到 :ref:`mysql` 。 :ref:`k3s` 项目有一个开源 `k3s-io/kine <https://github.com/k3s-io/kine>`_ 提供了相似但更为丰富的功能(支持更多数据库引擎):

- 使用传统的经过充分验证的关系型数据库(RDBMS)，可以避免重复建设分布式 :ref:`etcd` 的软硬件投资，节约成本
- 头部互联网公司跨机房、跨地域的数据库容灾系统经过多年建设，并且有成熟的容灾经验
- 传统数据库有经验丰富的DBA团队，也容易招聘和培养

不管怎样，殊途同归，开源的 `k3s-io/kine <https://github.com/k3s-io/kine>`_ 给予我们一个契机来结合传统DB和现代容器调度系统数据持久化存储的方案，我准备在后续部署 :ref:`k3s` 和 :ref:`k0s` 时进行实践。

...待更新实践

参考
======

- `Minimal example of using kine <https://github.com/k3s-io/kine/blob/master/examples/minimal.md>`_
