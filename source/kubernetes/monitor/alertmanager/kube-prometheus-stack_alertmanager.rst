.. _kube-prometheus-stack_alertmanager:

============================================
``kube-prometheus-stack`` 配置AlertManager
============================================

``alertmanager.alertmanagerSpec.alertmanagerConfiguration``
==============================================================

``alertmanager.alertmanagerSpec.alertmanagerConfiguration`` 提供了指定 altermanager 的配置，这样就能够自己定制一些特定的 ``receivers`` ，不过可能更方便是直接 ``apply`` 

参考
======

- `Prometheus: Alerting <https://confluence.infn.it/display/CLOUDCNAF/3%29+Alerting>`_
- `[kube-prometheus-stack] Alertmanager does not update secret with custom configuration options #1998 <https://github.com/prometheus-community/helm-charts/issues/1998>`_ 提供了一个CRD配置思路待验证
- `How to overwrite alertmanager configuration in kube-prometheus-stack helm chart <https://stackoverflow.com/questions/71924744/how-to-overwrite-alertmanager-configuration-in-kube-prometheus-stack-helm-chart>`_
