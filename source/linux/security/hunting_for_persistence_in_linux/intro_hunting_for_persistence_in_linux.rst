.. _why_hunting_for_persistence_in_linux:

===========================================
为什么"寻找Linux被攻击后植入的持久化后门"
===========================================

我个人对系统运维有一定经验，但是对系统安全还是门外汉。正好找到菲律宾的数据科学初创公司 Thinking Machines Data Science 的云安全工程师 Pepe Berba 撰写的一个关于入侵者如何在被攻击Linux系统中植入持久化后门以及如何排查寻找这样的后门的技术博客。我感觉教程相对比较完整和浅显，适合作为入门了解以及学习。所以我翻译整理并做模拟演练，以期对安全攻防有一个初步了解。

原系列博客 `Hunting for Persistence in Linux <https://pberba.github.io/security/2021/11/22/linux-threat-hunting-for-persistence-sysmon-auditd-webshell/>`_ 分为6部分（最后一节尚未完成):

- :ref:`persistence_auditing_loging_webshells` - 介绍审计和日志系统构建，以及作为案例的 webshell 后门
- :ref:`persistence_account_creation_manipulation` - 账号创建和篡改
- :ref:`persistence_systemd_timers_cron` - 创建和修改systemd服务，系统定时器和定时任务
- :ref:`persistence_init_scripts_shell_config` - 初始化脚本和shell配置
- :ref:`persistence_systemd-generators` - systemd-generators
- :ref:`persistence_rootkits_compromised_software` - 后门系统和破坏性软件

`Hunting for Persistence in Linux <https://pberba.github.io/security/2021/11/22/linux-threat-hunting-for-persistence-sysmon-auditd-webshell/>`_ 系列技术博客是采用了 `MITRE ATT&CK Matrix for Linux <https://attack.mitre.org/matrices/enterprise/linux/>`_ 系列的技术列表构建 入侵检测 ( ``offense informs defense`` )。

.. note::

   `MITRE ATT&CK <https://attack.mitre.org>`_ 是一个全球可访问的基于真实世界观察的对手战术和技术知识库。ATT&CK 知识库被用作在私营部门、政府以及网络安全产品和服务社区中开发特定威胁模型和方法的基础。ATT&CK是一个开放系统，可提供任何个人或组织免费使用。


参考
======

- `Hunting for Persistence in Linux: Overview of blog series <https://pberba.github.io/security/2021/11/22/linux-threat-hunting-for-persistence-sysmon-auditd-webshell/#overview-of-blog-series>`_
