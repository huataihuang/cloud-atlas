.. _grafana-pcp:

=====================================
Performance Co-Pilot Grafana Plugin
=====================================

安装
======

- :ref:`fedora` 安装非常简便:

.. literalinclude:: grafana-pcp/dnf_install_grafana-pcp
   :caption: Fedora上通过dnf安装grafana-pcp

- 如果发行版没有提供安装包，可以安装GitHub提供的release:

.. literalinclude:: grafana-pcp/install_grafana-pcp
   :caption: 安装Grafana PCP plugin

安装以后在 Grafana ``Administration`` 面板的 ``Plugins`` 中能够找到 ``Performance Co-Pilot`` ，点击 ``Enable`` 激活



参考
======

- `grafana-pcp: Performance Co-Pilot Grafana Plugin <https://grafana-pcp.readthedocs.io/en/latest/>`_

