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

- 安装过程结合了:

  - :ref:`debian_init`

    - :ref:`host_time_init`
    - :ref:`run_sway`
    - :ref:`linux_chinese_view`
    - :ref:`fcitx_sway`

- 切换用户默认SHELL到 :ref:`zsh`

- 修订时区:

.. literalinclude:: ../../infra_service/ntp/host_time_init/local_timezone.sh
   :language: bash
   :caption: 配置上海本地时区

- 更新系统:

.. literalinclude:: ../../linux/debian/debian_init/apt_upgrade.sh
   :language: bash
   :caption: APT更新整个系统

- 字符集配置UTF-8:

.. literalinclude:: ../../linux/desktop/chinese/linux_chinese_view/localegen
   :language: bash
   :caption: 字符集支持UTF-8

- 安装中文字体:

.. literalinclude:: ../../linux/desktop/chinese/linux_chinese_view/apt_install_fonts-wqy
   :language: bash
   :caption: apt安装文泉驿字体

- 安装 :ref:`sway` 图形管理器:

.. literalinclude:: ../../linux/desktop/sway/run_sway/apt_install_sway
   :language: bash
   :caption: apt安装sway

- 修订 ``~/.zshrc`` 添加以下内容方便自动启动 ``sway`` :

.. literalinclude:: ../../linux/desktop/sway/run_sway/zshrc_sway
   :language: bash
   :caption: 复制sway个人配置

- 创建 ``sway`` 个人定制配置文件 ``~/.config/sway/config`` :

.. literalinclude:: ../../linux/desktop/sway/run_sway/sway_config
   :language: bash
   :caption: sway个人配置

- 配置 ``/etc/environment`` 添加以下环境变量适配QT5应用:

.. literalinclude:: ../../linux/desktop/sway/run_sway/qt5_app_environment
   :language: bash
   :caption: QT5应用环境变量 /etc/environment

- 安装中文输入法:

.. literalinclude:: ../../linux/desktop/chinese/fcitx/apt_install_fcitx
   :language: bash
   :caption: apt安装fcitx

- 配置 ``/etc/environment`` :

.. literalinclude:: ../../linux/desktop/chinese/fcitx/environment
   :language: bash
   :caption: 启用fcitx5环境变量配置 /etc/environment

- 安装应用软件:

.. literalinclude:: ../../linux/debian/debian_init/debian_init_app
   :language: bash
   :caption: debian系安装应用

- 重新登陆后自动进入 :ref:`sway`

- 在 ``sway`` 环境中，直接 ``Mod4+return`` 启动终端，然后执行 ``fcitx5-configtool`` 进行配置，完成配置后退出重新登陆即可输入中文

开发环境
=========

采用 :ref:`my_vimrc` 部署开发环境

- 基于 `Ultimate vimrc <https://github.com/amix/vimrc>`_ 定制

.. literalinclude:: ../../linux/desktop/vim/vimrc/my_vimrc/install_ultimate_vimrc.sh
   :language: bash
   :caption: 安装Ultimate vimrc Awsome版本

- 配置 ``~/.vim_runtime/my_configs.vim`` :

.. literalinclude:: ../../linux/desktop/vim/vimrc/my_vimrc/my_configs.vim
   :language: bash
   :caption: ~/.vim_runtime/my_configs.vim

- :ref:`my_vimrc` 基础依赖安装:

.. literalinclude:: ../../linux/desktop/vim/vimrc/my_vimrc/vimrc_ubuntu_dep_dev
   :language: bash
   :caption: 编译YouCompleteMe依赖软件安装

- 安装Rust:

.. literalinclude:: ../../rust/rust_startup/install_rust.sh
   :language: bash
   :caption: Liinux平台安装Rust 

- 安装 :ref:`golang` / :ref:`nodejs` :

.. literalinclude:: ../../linux/desktop/vim/vimrc/my_vimrc/vimrc_ubuntu_go_nodejs
   :language: bash
   :caption: 安装Go和node.js

- 配置 :ref:`go_proxy` :

.. literalinclude:: ../../golang/go_proxy/alias_go_proxy.sh
   :language: bash
   :caption: alias设置go代理

- 配置 :ref:`npm_proxy` :

.. literalinclude:: ../../nodejs/startup/npm_proxy/alias_npm_proxy.sh
   :language: bash
   :caption: alias设置npm代理

- 按需编译YouCompleteMe：

.. literalinclude:: ../../linux/desktop/vim/vimrc/my_vimrc/compile_youcompleteme.sh
   :language: bash
   :caption: 按需编译YouCompleteMe

现在，一切就绪，使用 ``vim`` 可以开始进行开发学习
