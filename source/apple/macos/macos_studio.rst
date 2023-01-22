.. _macos_studio:

==================
macOS工作室
==================

在 :ref:`macos_studio_startup` 我思考了不同的构建工作室的基础环境，例如虚拟化和容器化。我个人一直在不同的Linux环境和macOS环境中切换(有太多的设备和安装部署)，每次起步初始化确实也花费了不少时间。例如我有机会能短暂使用 :ref:`apple_silicon_m1_pro` ，但是很快又得切换回 :ref:`arch_linux` 的 :ref:`mbp15_late_2013` 。

理想的工作方式是全面采用容器化技术( :ref:`docker` )来构建，并结合 :ref:`kind` 模拟 :ref:`kubernetes` ，这样在不同的工作环境中，只要采用合适的镜像( :ref:`dockerfile` )以及基础运行环境，就能够无缝切换。

:ref:`homebrew`
==================

要实现完整的可移植工作环境(和 :ref:`linux` 对齐)，在macOS环境中使用 :ref:`homebrew` 来构建基础环境:

- 安装 homebrew :

.. literalinclude:: homebrew/install_homebrew
   :language: bash
   :caption: 通过网络安装Homebrew

- 安装必要工具:

.. literalinclude:: homebrew/brew_install
   :language: bash
   :caption: 在macOS新系统必装的brew软件

- 切换python3版本:

.. literalinclude:: homebrew/switch_python3_to_homebrew_version
   :language: bash
   :caption: 切换macOS的python3版本到homebrew提供的版本

:ref:`virtualenv` 和 :ref:`sphinx_doc`
=========================================

- 结合 :ref:`sphinx_doc` 同时安装和部署好 :ref:`virtualenv` :ref:`python` 开发环境

虚拟沙箱环境非常简单:

.. literalinclude:: ../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: ../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

- 安装Sphinx 以及 rtd :

.. literalinclude:: ../../devops/docs/write_doc/install_sphinx_doc
   :language: bash
   :caption: 通过virtualenv的Python环境安装sphinx doc
