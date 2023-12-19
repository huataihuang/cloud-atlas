.. _intro_opensearch:

===================
OpenSearch简介
===================

缘起
=======

2021 年初，开源搜索和数据分析引擎 Elasticsearch 背后的母公司 ——Elastic 宣布变更 Elasticsearch 和 Kibana 的开源许可证，将原本的 Apache License 2.0 变更为双授权许可，即 Server Side Public License (SSPL) + Elastic License，两者都不是符合 OSI 定义的开源 License。

.. note::

   `opensource.org 官方博客: The SSPL is Not an Open Source License <https://blog.opensource.org/the-sspl-is-not-an-open-source-license/>`_ 声明 ``fauxpen`` 源代码许可证剥夺了用户权利: 允许用户查看源代码，但不允许受开源定义保护的其他非常重要的权利，例如将该程序用于任何领域的权利

   参考 `wikipedia: Server Side Public License <https://en.wikipedia.org/wiki/Server_Side_Public_License>`_ :

   - SSPL 是 MongoDB 2018年推出的 source-available （源代码提供)许可证: 包含 GNU Affero 通用公共许可证版本 3 (AGPL v3) 的大部分文本和条款，但修改了其针对通过网络传输的软件的条款，要求任何提供 SSPL 许可软件功能的人作为服务向第三方发布的服务(无论是否修改) 必须根据 SSPL 发布其 **全部源代码** ，包括所有软件、API 以及用户自行运行服务实例所需的其他软件。 相比之下，AGPL v3 的等效条款仅涵盖许可作品本身。
   - SSPL 未被多方认可为自由软件，包括开源促进会 (OSI) 和多个主要 Linux 供应商，因为上述规定对特定使用领域存在歧视。

   Elastic License 是非商业许可证，核心条款是 **如果将产品作为 SaaS 使用则需要获得商业授权**

当时 Elastic 公司称此举主要是限制云服务提供商（如 AWS） **在没有回馈的情况下将 Elasticsearch 和 Kibana 作为一项服务提供给他人使用** ，以保护 Elastic 在开发免费和开放产品方面的持续投资。但变更许可证也意味着 Elasticsearch 和 Kibana 不再是真正的 “开源软件”（OSI 定义的开源）。

随后，AWS 宣布创建了一个 **自称真正开源** 的 ``OpenSearch`` 分支( `opensearch.org <https://opensearch.org/>`_ )，并获得了包括红帽、SAP、Capital One 和 Logz.io 等在内的多个组织和厂商的支持。

OpenSearch 是一个由社区驱动的开源搜索和分析套件，包括企业安全、异常检测、告警、机器学习、SQL、索引状态管理等功能， ``fork`` 自 Apache License 2.0 许可的 **Elasticsearch 7.10.2 和 Kibana 7.10.2** 。它由一个搜索引擎守护程序 (OpenSearch)、一个可视化和用户界面 (OpenSearch Dashboards) 以及 Open Distro for Elasticsearch 的高级功能组成。

.. note::

   目前来看， ``Elasticsearch`` 由于开源许可证原因，在商业使用上可能比较合适，但是对于直接使用开源软件的企业和个人不一定适用。

   ``Elasticsearch`` 和 ``OpenSearch`` 分别发展，目前未知前景，两者都需要实践。

参考
=====

- `AWS 从 Elastic “抢” 来的开源替代品 OpenSearch，成功了吗？ <https://www.oschina.net/news/241162/opensearch-vs-elasticsearch>`_
