.. _ubicloud:

========================
Ubicloud
========================

Ubicloud是2023年创建的开源云平台，目标声明为 ``Open source alternative to AWS`` 。

这是一个类似 OpenStack 的开源云计算平台，但是切入市场的策略不同:

- 提供一个轻量级的开源云计算平台: 对比 OpenStack 数十甚至更多的复杂组件，Ubicloud则聚焦简单易用，提供一个轻量级的平替
- 使用 :ref:`ruby` 开发，但是使用了 `Roda <https://github.com/jeremyevans/roda>`_ 框架构建，以及采用 :ref:`pgsql`   作为数据库后端

Ubicloud 特色是提供了 :ref:`pgsql` 管理，通过本地 :ref:`nvme` 存储部署能够得到极佳性能以及较低的运行成本。这个管理能力源自 ``Citus Data`` : Ubicloud的开发团队也是 PostgreSQL 分析平台 ``Citus Data`` 的核心开发，该公司在2012年在YC孵化后，于2019年被微软收购。

Ubicloud看到OpenStack由于历史原因形成了复杂的侧重于数据集成公司的庞大架构，发现轻量级虚拟化可能是一个市场机会，所以切入这个精简虚拟化竞争赛道。主推简化部署、精简核心组件以及和现代化的 :ref:`kubernetes` 集成能力。

虽然Ubicloud公司目前规模极小(可能只有几十个员工)，并且还没有类似OpenStack这样成熟的社区支持，但是它切入的小而美的虚拟化管理平台:

- 提供极具特色的 :ref:`pgsql` 管理(OpenStack专注于系统集成领域，不涉及数据库服务)
- 吸收了近十年计算机技术发展红利: SPDK技术、IPv6、 :ref:`systemd` 提供cgroup管理、裸金属服务器支持(现在OpenStack也支持裸金属)

当然，和 OpenStack 相比 UbiCloud 还没有久经历史考验的成熟代码，也没有庞大的社区支持，文档匮乏。不过，其轻量级简化架构，在小型到中型的企业环境，可能有一定的市场前景。

.. note::

   本文是对UbiCloud的调研总结，我目前还没有实际使用过UbiCloud，这里仅记录，以后可能会在部署学习OpenStack时候做对比实践。

参考
=======

- `Ubicloud (UC W24) <https://www.workatastartup.com/companies/ubicloud>`_
- `Ubicloud wants to build an open source alternative to AWS <https://techcrunch.com/2024/03/05/ubicloud-wants-to-build-an-open-source-alternative-to-aws/>`_
