.. _mobile_pi_dev:

============================
移动开发:树莓派开发环境构建
============================

我在最初的 :ref:`mobile_work_think` 方案中，是想采用 :ref:`macos` 的 MacBook Pro来实现的: 我从2011年自费购买了MacBook Air 11" 就一直使用 :ref:`apple` 家的系列产品，确实是非常成熟的软硬件融合的生态。不过，2022年3月，魔都一个多月疫情封闭在家，我开始折腾 :ref:`pi_400` 运行 :ref:`sway` (基于 :ref:`wayland` 的平铺式窗口管理器)，意外发现 ``wayland+sway`` 居然能够充分释放 :ref:`raspberry_pi` 的性能，这触发我思考用日常 :ref:`linux_desktop` 来完成所有开发运维，磨炼技术的方案。

Raspberry Pi OS
=================

我在 :ref:`raspberry_pi` 上使用过多种Linux发行版:

- :ref:`ubuntu_linux` : :ref:`arm_k8s_deploy`
- :ref:`alpine_linux` : :ref:`pi_k3s_deploy`
- :ref:`kali_linux` : :ref:`install_kali_pi` 并 :ref:`run_sway`

不过，上述第三方Linux for :ref:`raspberry_pi` 各自有一些限制，对于充分发挥树莓派性能以及特有功能存在不足。所以最终，作为图形桌面，我还是回归到树莓派官方提供的 ``Raspberry Pi OS`` :

- 官方 ``Raspberry Pi OS`` 提供了针对树莓派硬件配置的 ``raspi-config`` 工具，可以非常方便调整系统设置
- 官方 ``Raspberry Pi OS`` 升级包含了firmware升级，可以为系统带来更多改进
- 出现和树莓派硬件相关的问题更容易找到参考资料

安装Raspberry Pi OS
=======================

- 安装过程非常简单，以下仅记录一些特定点

- 修订时区:

.. literalinclude:: ../../infra_service/ntp/host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区

- 更新系统:

.. literalinclude:: ../../linux/ubuntu_linux/debian_init/apt_upgrade.sh
   :language: bash
   :caption: APT更新整个系统

- 安装 :ref:`sway` 图形管理器::

   sudo apt install sway

安装完成后，执行 ``sway`` 就可以进入桌面，不过为了能够更为方便，修订 ``~/.zshrc`` 添加以下内容方便自动启动 ``sway`` :

.. literalinclude:: ../../linux/desktop/sway/run_sway/zshrc_sway
   :language: bash
   :caption: 复制sway个人配置

- 安装应用软件、中文字体和输入法
