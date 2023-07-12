.. _lmsensors_pmda:

========================
lmsensors PMDA
========================

``lmsensors PMDA`` 提供主板 lm sensors 的信息

安装
=======

- 确保 ``/usr/bin/sensors`` 已经存在，这个工具通常由 ``lm_sensors`` 软件包提供，例如在 :ref:`redhat_linux` 中使用 :ref:`dnf` 安装::

   dnf install lm_sensors

Ubuntu的软件包名字是 ``lm-sensors`` ::

   apt install lm-sensors

- 安装:

.. literalinclude:: lmsensors_pmda/install_lmsensors_pmda
   :caption: 安装 ``lmsensors PMDA``

参考
=====

- `lmsensors PMDA README.md <https://github.com/performancecopilot/pcp/tree/main/src/pmdas/lmsensors>`_
