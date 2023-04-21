.. _helm_dependency:

=====================
helm依赖(dependency)
=====================

当我们使用 ``helm`` 轻快(其实很复杂)地 :ref:`helm3_prometheus_grafana` ，我们既惊讶于部署速度，又迷惑于复杂的底层架构(到底有多少组件和参数呢)。实际上， ``helm`` 用一种类似于 :ref:`rpm` 的 ``chart`` 依赖管理，例如 `prometheus-community/helm-charts/charts/kuber-prometheus-stack/Chart.yaml <https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml>`_ 就配置了 ``kube-prometheus-stack`` Chart 所依赖的上游 Charts 。你可以通过 ``helm dependency build`` 和
``helm dependency update`` 来构建自己的helm并进行定制，

举例::

   helm dependency build alertmanager
   helm dependency update alertmanager

.. note::

   后续补充实践...

参考
========

- `How can I create my own helm chart package from the kube-prometheus-stack charts on github <https://stackoverflow.com/questions/75434281/how-can-i-create-my-own-helm-chart-package-from-the-kube-prometheus-stack-charts>`_
- `helm dependency build <https://helm.sh/docs/helm/helm_dependency_build/>`_
- `helm dependency update <https://helm.sh/docs/helm/helm_dependency_update/>`_
- `prometheus-community/helm-charts/charts/kuber-prometheus-stack/Chart.yaml <https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/Chart.yaml>`_
