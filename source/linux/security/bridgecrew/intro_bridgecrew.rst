.. _intro_bridgecrew:

==================
Bridgecrew简介
==================

`Bridgecrew by Prisma Cloud <https://docs.bridgecrew.io/>`_ 是 `Prisma Cloud <https://www.paloaltonetworks.com/prisma/cloud>`_ 的自动化安全引擎，专注于代码和云架构的漏洞发现和修复。

特性:

- 云和代码安全: 查找 IaC、Secrets、Images、SCA 等中的错误配置和漏洞，使用简化的策略管理来管理应用程序和基础设施开发
- 补救措施(remediation): 自动生成的代码修复程序可以修复和修补易受攻击的代码 (有点类似GitHub的Dependabot/Code scanning/Secret scanning)
- 多生态集成: 提供30多个生态集成以及功能齐全的CLI、API和Terraform provider，开发者可以选择和自定义自己的工具链应用程序
- 资产追踪: 使用可追溯性标签，用户可以定位基于特定 IaC 资源创建的云资源、检测 IaC 模板的偏差并跟踪云和代码之间的差异
- 供应链安全: 应用程序依赖关系的全面清单和可视化

.. note::

   `Prisma Cloud <https://www.paloaltonetworks.com/prisma/cloud>`_ 是 `Palo Alto Networks <https://www.paloaltonetworks.com/>`_ 旗下的解决方案之一。 `Palo Alto Networks中文官网 <https://www.paloaltonetworks.cn/>`_ 有关于该公司解决方案的介绍:

   - 全球网路安全领导者，专注于云计算(内部、云交付、云原生、边缘云、运营)的全面解决方案

这是一个非常有特色的安全技术领域，从 `Bridgecrew by Prisma Cloud <https://docs.bridgecrew.io/>`_
文档中可以看到，这个产品是集成到软件仓库、云计算、持续集成、IDE开发环境以及Kubernetes和私有仓库的安全工具。当平台给予Bridgecrew管理员级别权限，该自动化引擎会扫描系统，给出漏洞、风险评估以及对应的解决方案。虽然Bridgecrew不是开源软件(实际是SaaS)，但是它的架构理念、后端策略(例如 :ref:`k8s_policy` )、以及集成的开源组件是非常值得研究借鉴的:

- :ref:`checkov` : infrastructure as code(IaC)的静态代码分析工具

在 `Bridgecrew by Prisma Cloud <https://docs.bridgecrew.io/>`_ 文档网站可以参考云计算配置的建议，了解设置的优缺点，不断改进自己的部署:

- 我在 :ref:`k8s_policy` 中借鉴和实践

.. note::

   Bridgecrew服务是一个SaaS(Software as a service) Security，其构建架构在大型软件、互联网公司有很强的市场。

   我想在后续找机会学习实践...

参考
=======

- `What is Bridgecrew? <https://docs.bridgecrew.io/docs/what-is-bridgecrew>`_
