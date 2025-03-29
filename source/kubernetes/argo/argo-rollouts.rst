.. _argo_rollouts:

========================
Argo Rollouts
========================

Argo Rollouts 是一个 :ref:`k8s_controller` 和 一组 :ref:`k8s_crd` ，为Kubernetes提供了高级的部署能力，例如 蓝绿，金丝雀，金丝雀分析，实验以及渐进式提交的能力。

(可以选择)Argo Rollouts和 :ref:`k8s_ingress` 以及 service meshes 集成，利用其流量整形(traffic shaping)能力实现在更新期间逐渐将流量转移到新版本。(你可以理解成提供了一种比较巧妙的方式实现负载均衡)

此外，Rollouts可以查询和解释来自不同providers的metrics，这样就可以验证关键KPIs以及在更新期间提供自动化提示(promotion)或回滚(rollback)。(你可以理解成提供了对各种监控指标metrics的检查，以及自动交互，帮助管理者判断和回滚发布)

``Argo Rollouts`` vs. ``Kubernetes原生RollingUpdate``
======================================================

``Kubernetes原生RollingUpdate``
--------------------------------

原生的Kubernetes :ref:`deployment` 对象在更新过程中支持提供基本的安全保障集(就绪探针, readiness probes)，也就是 ``RollingUpdate`` 策略。然而这种滚动更新策略有一席限制:

- rollout的速度控制非常少
- 无法控制新版本的流量
- 就绪探针(readiness probes)不适合更深入、压力或者一次性监测
- 无法查询外部指标(query external metrics)来验证更新 (这个功能很重要，生产环境中系统自身监控反应不出问题，但是外部依赖这个系统的平台可能已经出现了故障)
- 可以停止进度，但是无法自动中止和回滚更新

由于这些原因，在大规模高容量的生产环境，滚动更新通常被认为更新风险太大: 无法控制爆炸半径，并且可能由于过于激进rollout导致故障，并且在失败时不能提供自动回滚

.. note::

   有一种思路是将集群规模控制在合适大小，通过联邦方式来管理多集群，并实现 :ref:`workload_resources` 的跨集群调度

   `从滴滴的故障中我们能学到什么
   <https://mp.weixin.qq.com/s?__biz=MjM5MDE0Mjc4MA==&mid=2651189960&idx=1&sn=1338eb80368500e337ba0e98e89e6e8a&chksm=bdb80a9b8acf838dc8f736805d4f96b8e774ab5a2b01c41d4be7e636746c28dab75f2a990776&mpshare=1&scene=1&srcid=1210qqHuCSo5mCmVtzE0Z4GD&sharer_shareinfo=6045e78f3dcaf34c8a570f9c87e53293&sharer_shareinfo_first=6045e78f3dcaf34c8a570f9c87e53293&exportkey=n_ChQIAhIQ5FzWtIkFciMtbeX%2BzGYa7RKZAgIE97dBBAEAAAAAANquLTAqNGkAAAAOpnltbLcz9gKNyK89dVj0DU8ehEVjHjlVD3iB3br%2Fo2hybhK5P8nozywmcPwbFdvKXHtD4J4obUYiDm%2F7mawgn8FdIg7H1xh28RpCUMis3CCWfvEgmX2kNszU0hJ8WqI6bwpciqGd3j8z%2BoNfUE9VWOPVaB4oJLTxnecuMb5TEtuVtzb%2BPnBfWngJ72H4etmIg8vVn8FZaFpd3Epm83yNUpPPOdEmdooF7Mk0CjcbAZQGOK4IFrAMNe%2B9VqwScNtbONBpBI99EnPZZ5f%2B1TzmQBVvjCAPr1dEViYYpSd00O5htyKtxo8L0hDA4%2BEijPfB8logpvUqBXlXIMQqNoZORREa&acctmode=0&pass_ticket=jOPhYaWiahcytSnP73s8M%2BxkKXuVYPqLhWBQuJEfdnMdmEgJlsJBxnnuqfCzm69z7m68kPmyveMH7LZAFVLdtw%3D%3D&wx_header=0#rd>`_ 

``Argo Rollouts`` 增强
-----------------------

- 蓝绿更新策略
- 金丝雀更新策略
- 细粒度、加权流量转移
- 自动回滚和提示(promotions)
- 手动判断
- 可定制的业务KPI指标查询与分析
- 入口控制器集成：NGINX、ALB
- 服务网格集成：:ref:`istio` 、Linkerd、SMI
- 指标提供者(metrics provider)集成：Prometheus、Wavefront、Kayenta、Web、Kubernetes

参考
======

- `What is Argo Rollouts? <https://argoproj.github.io/rollouts/>`_
