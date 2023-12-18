.. _think_k8s:

====================
Kubernetes的思考
====================

Kubernetes的高速发展是围绕这个生态的企业所推动的，这也和CNCF的企业运作模式有关。企业会将自己的需求推动进入CNCF孵化，并且尽快产品化。所以这个生态鱼龙混杂，存在过度复杂化的趋势。

对于个人和中小企业，如果规模无法做到数百物理服务器，上万的应用容器，那么部署Kubernetes是非常不经济和低效的: 考虑到恐怖的复杂架构，和云厂商深度绑定，如果业务无法带动这样的技术规模，你的IT投入可能远超你部署少量VM就能完成的技术成本。

37signals
=============

传奇的企业 `37signals <https://37signals.com/>`_ (SaaS)在2023年 `Breaking Free From the Cloud With Mrsk: Just Enough Orchestration for Your Apps <https://semaphoreci.medium.com/breaking-free-from-the-cloud-with-mrsk-just-enough-orchestration-for-your-apps-caa56631f3d1>`_ 给予我们的启示

`kamal-deploy <https://kamal-deploy.org/>`_ 研发的 :ref:`kamal` 是一种简化版调度管理系统，用于部署Docker系统，最初是为 :ref:`rails` 应用开发的，现在已经可以部署任何web应用。
