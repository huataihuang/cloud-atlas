.. _get_pods_special_node:

====================
获取特定节点的pods
====================

我们在生产环境会有一种查询需求:

找出特定(labels)服务器上运行的所有pods

这个操作可以解析为2步:

- 找出特定(labels)服务器

  - ``-l <labels>`` 根据节点label查询
  - ``-ojsonpath='{.items[*].metadata.name}'`` 仅输出节点名

- 查询出这批服务器上应用pods

  - ``--field-selector spec.nodeName=$node``

完整案例::

   # 这里案例采用查询出集群中ARM服务器节点上pods
   LABEL="kubernetes.io/arch=arm64"
   for node in $(kubectl get nodes -l $LABEL -ojsonpath='{.items[*].metadata.name}'); do kubectl get pods -A -owide --field-selector spec.nodeName=$node; done

.. note::

   Kubernetes目前支持AND交集的多标签查询，也即是只支持同时满足多个标签的节点查询，但不支持这些标签的OR满足

   不过，Kubernetes还是支持一个单一标签的多个值的OR查询::

      kubectl get pods -l 'app in (foo,bar)'

pod标签
==========

如果可行，可以在pod上增加一些特定标签，这将大大方便查询。例如，将上述节点架构标签也加入到pods上，那么查询的时候就不需要拆分成2步(先查节点,再查节点上的pod)，可以一步到位，结合多个标签进行查询::

    kubectl get pods -A -owide --selector kubernetes.io/arch=arm64,labelXXX,labelYYY

参考
=====

- `Get pods on nodes with certain label <https://stackoverflow.com/questions/63587304/get-pods-on-nodes-with-certain-label>`_
- `Querying pods by multiple labels <https://stackoverflow.com/questions/64258213/querying-pods-by-multiple-labels?answertab=trending#tab-top>`_
