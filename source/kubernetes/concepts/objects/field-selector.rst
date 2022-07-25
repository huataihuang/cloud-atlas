.. _field-selector:

==========================
field-selector 字段选择器
==========================

字段选择器(Field selectors)可以根据一个或多个资源字段值筛选kubernetes资源。以下是一些案例:

- ``metadata.name=my-service``
- ``metadata.namesapce!=default``
- ``status.phase=Pending``

.. note::

   在 :ref:`get_pods_special_node` 就是通过 ``--field-selector`` 字段选择器来过滤出指定主机上的pods

以下案例查询出状态 ``status.phase`` 为 ``Running`` 的Pods::

   kubectl get pods --field-selector status.phase=Running

操作符
=========

字段选择器可以使用 ``=`` / ``==`` / ``!`` 操作符( ``=`` 和 ``==`` 意义相同 )

链式选择器(也就是 ``AND`` 逻辑)
==================================

可 :ref:`labels_and_selectors` 一样，字段选择器可以使用逗号分隔的列表组成选择链(也就是相当于 逻辑 ``AND`` )，以下案例将删选 ``status.phase`` 字段不等于 ``Running`` 同时 ``spec.restartPolicy`` 字段等于 ``Always`` 的所有Pods::

   kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always

过滤daemonset
==============

在 :ref:`get_pods_special_node` 场景中，我们可能只需要查询出普通的 ``pods`` ，但过滤掉 :ref:`daemonset` ，则可以利用 ``daemonset`` 都具备的字段过滤 ``schedulerName: kubernetes.io/daemonset-controller`` ::

   kubectl get pods -A -owide --field-selector=spec.nodeName=$node,schedulerName!=kubernetes.io/daemonset-controller

**很不幸，这里会报错** ::

   Error from server (BadRequest): Unable to find "/v1, Resource=pods" that match label selector "", field selector "spec.nodeName=i-uf6i7oryfhjqlfbqiacw,schedulerName!=kubernetes.io/daemonset-controller": field label not supported: schedulerName

我暂时还没有找到解决方法，目前比较土的方法是对已知的 ``daemonset`` 对结果进行一遍过滤。后续等我学习和理解更深再尝试解决。


参考
=====

- `Kubernetes 文档: 字段选择器 <https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/field-selectors/>`_
