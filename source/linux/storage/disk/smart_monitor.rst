.. _smart_monitor:

=======================
存储设备S.M.A.R.T监控
=======================

我的二手 :ref:`hpe_dl360_gen9` 服务器使用了一块我很久以前购买的Intel SATA SSD磁盘，不过这块SSD时不时在系统日志中留下触目惊心的Err记录:

.. literalinclude:: smart_monitor/dmesg_ssd_error
   :caption: ``dmesg`` 中SSD磁盘错误日志

我想通过存储的 S.M.A.R.T. 技术来检测和监视磁盘的异常:

- 本文的 ``smartctl`` 命令行检查(基础能力)
- :ref:`node_exporter_smartctl_text_plugin` 通过自己部署的 Prometheus + Grafana 监控来直观观察

参考
========

- `arch linux - S.M.A.R.T. <https://wiki.archlinux.org/title/S.M.A.R.T.>`_
- `Monitor and Analyze Hard Drive Health with Smartctl in Linux <https://www.linuxtechi.com/smartctl-monitoring-analysis-tool-hard-drive/>`_ 非常详细的命令行解析
- `How to check an hard drive health from the command line using smartctl <https://linuxconfig.org/how-to-check-an-hard-drive-health-from-the-command-line-using-smartctl>`_
- `SMART tests with smartctl <https://www.thomas-krenn.com/en/wiki/SMART_tests_with_smartctl>`_
