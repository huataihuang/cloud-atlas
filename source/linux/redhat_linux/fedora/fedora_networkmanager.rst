.. _fedora_networkmanager:

================================
Fedora NetworkManager网络管理
================================

在现代的最新发行版，例如 :ref:`ubuntu_linux` 以及 :ref:`fedora` 都已经全面采用 :ref:`networkmanager` 来管理网络配置。我在之前Ubuntu系统中实践的 :ref:`networkmanager` ，现在也同样用于Fedora ( :ref:`mobile_cloud_infra` )管理网络。

:ref:`networkmanager` 管理采用命令行 ``nmcli`` 完成，可以实现复杂的管理功能。本文概述实践步骤，提供一个快速参考。

- ``nmcli con`` 可以检查网络连接，对于 :ref:`fedora` 虚拟机:

.. literalinclude:: fedora_networkmanager/nmcli_con
   :language: bash
   :caption: nmcli con查看网络连接

显示输出可以看到当前网络连接命令是 ``enp1s0`` ，我们后面将使用这个命令来修订网络配置:

.. literalinclude:: fedora_networkmanager/nmcli_con_output
   :language: bash
   :caption: nmcli con查看网络连接输出信息

- 执行以下 ``nmcli con mod`` 命令来 ``connection modify`` 配置静态IP地址(针对 ``enp1s0`` ):

.. literalinclude:: fedora_networkmanager/nmcli_con_static_ip
   :language: bash
   :caption: nmcli con mod (connection modify) 修改网络配置(静态IP)

