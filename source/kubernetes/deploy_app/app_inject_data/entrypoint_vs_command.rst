.. _entrypoint_vs_command:

===============================
ENTRYPOINT和COMMAND差异和协作
===============================

:ref:`dockerfile` 定义 和 Kubernetes 的定义有差异和混淆，以下是对应关系

.. csv-table:: Docker和Kubernetes的ENTRYPOINT和COMMAND的对应关系
   :file: entrypoint_vs_command/entrypoint_vs_command.csv
   :widths: 40,30,30
   :header-rows: 1

参考
======

- `Difference between Docker ENTRYPOINT and Kubernetes container spec COMMAND? <https://stackoverflow.com/questions/44316361/difference-between-docker-entrypoint-and-kubernetes-container-spec-command>`_
- `为容器设置启动时要执行的命令和参数 <https://kubernetes.io/zh-cn/docs/tasks/inject-data-application/define-command-argument-container/>`_
