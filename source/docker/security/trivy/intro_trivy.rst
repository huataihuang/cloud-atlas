.. _intro_trivy:

========================
Trivy容器漏洞扫描器简介
========================

`aqua trivy <https://aquasecurity.github.io/trivy>`_ 容器漏洞和误配置扫描器是 Aqua Security 公司开发的开源安全工具。 ``Trivy`` 可以检测操作系统软件包以及特定语言的漏洞，以及扫描IaC文件(Infrastructure as Code, 基础设施即代码)如 Terraform 和 :ref:`kubernetes` 的配置问题来发现被攻击的风险。

.. figure:: ../../../_static/docker/security/trivy/trivy_overview.png
   :scale: 50

- 漏洞检测案例:

.. figure:: ../../../_static/docker/security/trivy/trivy_vuln-demo.gif
   :scale: 35

- 错误配置检测案例:

.. figure:: ../../../_static/docker/security/trivy/trivy_misconf-demo.gif
   :scale: 35

参考
=======

- `aqua trivy <https://aquasecurity.github.io/trivy>`_
