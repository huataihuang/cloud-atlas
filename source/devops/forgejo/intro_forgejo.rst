.. _intro_forgejo:

======================
Forgejo简介
======================

在 Git 托管与 DevOps 领域，:ref:`gitlab` 、:ref:`gitea` 和 :ref:`forgejo` 代表了两种完全不同的设计哲学：一种是"全栈全能的单体平台(All-in-One)"，另一种是"极简高效的代码托管与轻量协作工具"。

GitLav vs. Gitea vs. Forgejo
==============================

架构与定位
-------------

- :ref:`gitlab` : 采用 :ref:`rails` 、 :ref:`golang` 、Vue.js 等构建的庞大单体平台。它的目标是覆盖 DevOps 的整个生命周期(从需求管理、代码托管、CI/CD、安全扫描、镜像仓库到监控)。
- :ref:`gitea` : 使用 :ref:`golang` 编写的单一二进制文件。它的定位是轻量级、低消耗、极速响应的代码托管系统，主打极简的 Git 体验。
- :ref:`forgejo` : 是 Gitea 的开源分支（Fork）。由于 2022 年 Gitea 的核心团队成立了商业公司（Gitea Ltd），社区担心其开源独立性受到威胁，因此由 Codeberg 社区主导发起了 Forgejo。Forgejo 强调真正的社区驱动与开源中立性。

技术栈对比
-----------------

.. csv-table:: GitLab vs. Gitea vs. Forgejo
   :file: intro_forgejo/gitlab_gitea_forgejo.csv
   :widths: 10,30,30,30
   :header-rows: 1

企业市场对比
-------------

在传统和中大型企业（Enterprise）市场中，GitLab 占据着绝对的优势:

- 开箱即用的 ``DevSecOps`` 闭环: 大型企业不喜欢拼积木。GitLab 提供了合规审计(Compliance)、安全扫描(SAST/DAST/依赖分析)、项目管理(Epics/Roadmaps)和镜像仓库。企业不需要去对接 Jenkins + SonarQube + Jira，买套 GitLab 就全有了。
- 企业级的细粒度权限控制(RBAC): GitLab 的 ``Group/Sub-group/Project`` 层级架构非常适合复杂的企业组织架构。它提供了极其精细的分支保护、代码评审(Merge Request Approval Rules)、SAM/LDAP 深度集成以及审计日志(Audit Events)。
- 高可用与大规模横向扩展: GitLab 拥有极度成熟的云原生部署方案(GitLab Helm Chart)，支持分布式 :ref:`pgsql` 、 :ref:`redis` 集群、Gitaly Cluster(Git 存储高可用)，能够轻松支撑数万名研发人员的高并发访问。
- 商业支持与合规背书: 大型企业采购往往需要 SLA 保证、商业安全责任兜底以及 ISO/SOC2 等合规认证，GitLab 公司能提供完善的商业服务。

虽然 GitLab 统治着中大型企业，但在以下场景中，Gitea/Forgejo 正在迅速侵蚀其份额:

- GitLab 资源开销过度臃肿: 许多中小企业、边缘计算节点或自建 Homelab，只需要"代码托管 + 基础 CI"，为此运行一个动辄吃掉 8G 内存、十几个容器的 GitLab 显得极其浪费。
- GitHub Actions 生态的崛起: Gitea 和 Forgejo 原生引入了对 GitHub Actions 语法 的支持(Gitea/Forgejo Actions)。这意味着开发者可以直接复用 GitHub 生态中庞大的开源 Action 插件，大大降低了编写 CI/CD 流程的门槛。
- Forgejo 的"开源纯洁性"号召力: 在欧洲以及许多重视数据主权、反对厂商锁定的组织（例如 Codeberg 托管平台、诸多 Linux 发行版社区）中，Forgejo 正在成为替代 GitLab 的第一选择。

Forgejo的DIY
==============

由于我个人构建 `Cloud Atlas <https://cloud-atlas.dev>`_ 硬件环境有限(租用虚拟机)，并且也只是个人(小团队)，同时我想更深入的实践和掌握不同开源CI/CD软件的组合，所以我选择 Forgejo 作为基础发布平台:

- 自动化编译发布 :ref:`sphinx-doc` 来完成我的个人技术分享
- 自动编译和发布 :ref:`golang` , :ref:`rust` 以及 :ref:`clang` 的软件，并完成测试覆盖

参考
======

- gemini
