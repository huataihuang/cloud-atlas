.. _configmap:

====================
ConfigMap
====================

ConfigMap是Kubernetes的API对象，用于存储非机密性的数据，保存为键值对。通过 :ref:`config_pod_by_configmap` ，Pods就能够使用存储的环境变量、命令行参数或者存储卷中的配置文件。

ConfigMap不是用来保存大量数据的，在ConfigMap中保存的数据不能超过 ``1 MiB`` : 对于需要存储超过这个大小限制的数据，需要采用 :ref:`k8s_volumes` 或者独立的数据库或者文件服务器。

...

参考
=======

- `Kubernetes Documentation/Concepts/Configuration/ConfigMaps <https://kubernetes.io/zh-cn/docs/concepts/configuration/configmap/>`_
