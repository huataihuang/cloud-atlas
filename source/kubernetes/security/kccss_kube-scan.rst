.. _kccss_kube-scan:

============================================
Kubernetes配置安全扫描评估KCCSS和kube-scan
============================================

`Octarine <https://www.octarinesec.com>`_ 是Kubernetes安全公司，开发了两个开源康姆：

- kubernetes Common Configuration Scoring System(KCCSS) Kubernetes常用配置评估系统，一种对Kubernetes错误配置进行安全风险打分的框架
- kube-scan 扫描Kubernetes配置和设置以标记潜在漏洞的风险

当前Kubernetes提供了超过30项安全设置，但是开发团队往往缺乏安全经验，一旦错误配置就可能引入安全漏洞。KCCSS类似Common Vulnerability Scoring
System(CVSS)，工业标准的漏洞评估系统，但是聚焦在配置和安全设置。kube-scan则基于KCCSS用于分析超过30项安全设置以及权限级别配置，功能以及Kubernetes策略来建立风险基线。kube-scan可以显示哪些工作负载是更高风险，为什么有潜在的后果，并帮助更新Pod安全策略，Pod定义以及清单文件。kube-scan作为一个pod运行，但是禁止ingress或egress访问。它可以安全运行在任何环境并且可以在风险评估页面访问后删除。

KCCSS
=========

从Octarinesec的 `kccss GitHub <https://github.com/octarinesec/kccss>`_

kube-scan
============

`kube-scan GitHub <https://github.com/octarinesec/kube-scan>`_

参考
======

- `Octarine Open Sources the Kubernetes Common Configuration Scoring System and kube-scan <https://finance.yahoo.com/news/octarine-open-sources-kubernetes-common-140010027.html>`_
