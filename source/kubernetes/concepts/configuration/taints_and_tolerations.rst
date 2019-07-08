.. _taints_and_tolerations.rst:

=========================================
瑕疵和容忍(Taints and Tolerations)
=========================================

Node affinity(节点亲和性)是设置pod优先分配到一组nodes(例如性能或硬件要求)。而 ``taints`` 则相反，设置节点排斥pod。

taints和tolerations结合起来使用可以确保pod不会调度到不合适到节点。当一个或多个taints被应用到节点，则会标记节点不接受任何不容忍瑕疵的pods (not accept any pods that do not tolerate the tains)。当tolerations（容忍）被应用到节点，则允许（但不强求）pod调度到匹配瑕疵(taints)的节点上。

.. note::

   ``taints`` 和 ``tolerations`` 是结合使用的：从字面意思上就是 ``瑕疵`` 和 ``容忍`` 。当节点被标记为瑕疵( ``taints`` )，则默认不会调度到该节点。除非pod被标记为容忍( ``tolerations`` )这个瑕疵，则带有容忍这种瑕疵的节点才会被调度到对应有瑕疵的节点上。

参考
======

- `Kubernetes Documentation - Concepts: Taints and Tolerations <https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/>`_
