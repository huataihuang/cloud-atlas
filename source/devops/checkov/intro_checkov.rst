.. _intro_checkov:

===================
checkov简介
===================

checkov 是一个静态代码分析工具，用于扫描 ``基础架构即代码`` (infrastructure as code, IaC) 文件是否存在导致安全或合规性问题的错误配置。checkov内置了750多个预定义策略来检查常见的错误配置问题，还支持自定义策略的创建和贡献。

支持的IaC类型:

- Terraform (for AWS, GCP, Azure and OCI)
- CloudFormation (including AWS SAM)
- Azure Resource Manager (ARM)
- Serverless framework
- Helm charts
- Kubernetes
- Docker

.. note::

   目前我还没具体实践，但是我认为这是一个值得切入的细分技术领域，后续有合适的机会再验证实践

参考
======

- `What is Checkov? <https://www.checkov.io/1.Welcome/What%20is%20Checkov.html>`_
