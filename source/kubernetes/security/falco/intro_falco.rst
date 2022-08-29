.. _intro_falco:

========================
Falco运行时安全工具简介
========================

Falco( ``隼`` )项目是 `Sysdig <https://sysdig.com/>`_ 公司开源的云原生运行时安全工具(CNCF孵化项目)。Falco使得内核事件处理更为容易，并且结合Kubernetes和云原生堆栈的其余部分来丰富事件处理。Falco可以通过插件来扩展使用其他数据源。

Falco有丰富的安全规则，用于Kubernetes、Linux和云原生构建。如果系统中出现违反规则情况，Falco就会发送告警通知用户违规以及严重程度。

Falco功能
===========

Falco可以检测出任何涉及进行Linux系统调用的行为并发出警报，通过 :ref:`falco_drivers` 实现内核事件检测

Falco警报可以通过使用特定的系统调用、参数以及调用进程的属性来触发，可以检测到以下事件(包括但不限于):

- Kubernetes的容器或pod中运行的shell
- 容器在特权模式下运行，或者正在从挂载物理主机的敏感路径，如 ``/proc``
- 不符合预期地访问敏感文件，如 ``/etc/shadow``
- 一个非设备文件被写入到 ``/dev``
- 标准的系统二进制程序(如 ``ls`` )正在建立出站的网络俩节
- 一个特权pod在Kubernetes集群中启动



参考
======

- `Falco官方GitHub <https://github.com/falcosecurity/falco>`_
