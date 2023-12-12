.. _argo-rollouts:

========================
Argo Rollouts
========================

Argo Rollouts 是一个 :ref:`k8s_controller` 和 一组 :ref:`k8s_crd` ，为Kubernetes提供了高级的部署能力，例如 蓝绿，金丝雀，金丝雀分析，实验以及渐进式提交的能力。

(可以选择)Argo Rollouts和 :ref:`k8s_ingress` 以及 service meshes 集成，利用其流量整形(traffic shaping)能力实现在更新期间逐渐将流量转移到新版本。(你可以理解成提供了一种比较巧妙的方式实现负载均衡)

此外，Rollouts可以查询和解释来自不同providers的metrics，这样就可以验证关键KPIs以及在更新期间提供自动化提示(promotion)或回滚(rollback)。(你可以理解成提供了对各种监控指标metrics的检查，以及自动交互，帮助管理者判断和回滚发布)

``Argo Rollouts`` vs. ``Kubernetes原生RollingUpdate``
======================================================



参考
======

- `What is Argo Rollouts? <https://argoproj.github.io/rollouts/>`_
