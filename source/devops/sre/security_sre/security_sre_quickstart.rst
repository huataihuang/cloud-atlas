.. _security_sre_quickstart:

==============================
Security SRE快速起步
==============================

.. note::

   本文根据gemini提炼 `Building Secure & Reliable Systems: Best Practices for designing, Implementing and Maintaining Systems <https://google.github.io/building-secure-and-reliable-systems/raw/toc.html>`_

《Building Secure and Reliable Systems》书名非常清晰，构建安全可靠的系统!

一句工程准则:

**用清晰的不变式和分层隔离设计系统，用框架、测试与供应链自动化锁住实现与发布，用演练与冷静调查应对突发危机，最终靠人人可参与、默认走对路的工程文化把这一切长期运转下去。**

SRE的未来: AI+安全
==========================

随着 :ref:`machine_learning` 人工智能深刻且飞速推动 **现代大规模分布式系统** 如 :ref:`kubernetes` 的演进以及 :ref:`llm` 衍生出的安全攻防(系统漏洞和软件bug更快被发现和利用攻击)，SRE面对的是更为复杂的系统以及和受到安全影响的系统稳定性。

传统的分工中，SRE关注的"非恶意故障"(如硬件损坏、流量洪峰、代码 Bug 导致的宕机)，而安全团队关注的是"恶意攻击"。但是在云原生、 :ref:`kubernetes` 和自动化运维时代，攻击着往往直接利用 CI/CD 流水线、容器逃逸、系统软件bug或错误配置发动攻击 -- 这恰恰是SRE日常管理的核心基础设施。

因此，各大科技公司普遍设立了 **Security SRE** 或 **Production Security (生产环境安全)** 岗位。

**DevSecOps** 是 :ref:`devops` 工作的自然延伸，是和 **平台工程(Platform Engineering)** 高度契合的:

现代基础设施的核心理念将 ``安全能力`` 下沉到 **平台层** :

- 自动化的证书轮转
- 默认开启mTLS :ref:`zero_trust` 通信
- 不可变基础设施( :ref:`container` 化以及 :ref:`kubernetes` 编排)

这要求SRE不仅懂得大规模集群的调度与排障，也需要懂得 **底层的攻防技术** 

Security SRE核心
=====================

根据 `Building Secure & Reliable Systems: Best Practices for designing, Implementing and Maintaining Systems <https://google.github.io/building-secure-and-reliable-systems/raw/toc.html>`_ 一书的划分，从架构设计、代码实现到灾难恢复与组织文化，Security SRE的核心工作包括:

.. csv-table:: Security SRE核心
   :file: security_sre_quickstart/core.csv
   :widths: 20,80
   :header-rows: 1

参考
======

- gemini
