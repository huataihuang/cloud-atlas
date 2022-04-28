.. _debian_init:

====================
Debian精简系统初始化
====================

实际上，众多的Linux发行版都是基于Debian构建的，包括:

- :ref:`ubuntu_linux`
- :ref:`kali_linux`
- ``Raspberry Pi OS``

我在 :ref:`pi_400` 上构建 :ref:`mobile_pi_dev` 采用Lite版本安装后定制，安装初始化步骤是所有debian系共通的，整理汇总如下

- 修订时区:

.. literalinclude:: ../../infra_service/ntp/host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区

- 更新系统:

.. literalinclude:: debian_init/apt_upgrade.sh
   :language: bash
   :caption: APT更新整个系统

精简图形系统sway
=================

- 安装 :ref:`sway` 图形管理器::

   sudo apt install sway

安装完成后，执行 ``sway`` 就可以进入桌面，不过为了能够更为方便，修订 ``~/.zshrc`` 添加以下内容方便自动启动 ``sway`` :

.. literalinclude:: ../../linux/desktop/sway/run_sway/zshrc_sway
   :language: bash
   :caption: 复制sway个人配置

- 安装中文字体和输入法
