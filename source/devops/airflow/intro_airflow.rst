.. _intro_airflow:

================
Airflow简介
================

`Apache Airflow <https://github.com/apache/airflow>`_ 是一个开源的开发、调度和监控面向批处理的工作流平台。

.. figure:: ../../_static/devops/airflow/AirflowLogo.png

Airflow的特色:

- 完全采用Python开发，不需要使用命令行或者XML，只需要使用标准的Python功能来创建工作流就能实现任务调度和动态生成并不断循环
- 提供了图形界面监控、调度和管理工作流，可以检查状态以及完全的日志
- 提供集成到Google Cloud,AWS, Microsoft Azure等云计算服务
- 易于使用且开源

.. note::

   可以看到 Apache Airflow 是和 :ref:`temporal` 相似的工作流平台，此外在这个领域还有面向持续集成和工作流的 :ref:`argo`

参考
=====

- `What is Airflow? <https://airflow.apache.org/docs/apache-airflow/stable/index.html>`_
