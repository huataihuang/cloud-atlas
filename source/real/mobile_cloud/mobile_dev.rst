.. _mobile_dev:

================
移动开发
================

数字游牧
==========

对于开发运维人员，远程工作和移动开发是必然的选项; 而构建 :ref:`mobile_cloud_infra` 也包含了在本地构建一个开发工作环境

vim
-----

- 安装::

   pacman -S vim

- 默认启用vim替代vi，在环境配置文件 ``~/.bashrc`` 中添加::

   alias vi='vim'

- 采用 :ref:`my_vimrc` 完成设置:

.. literalinclude:: ../../linux/desktop/vim/my_vimrc/install_ultimate_vimrc.sh
   :language: bash
   :caption: 安装Ultimate vimrc Awsome版本

node.js
--------

- 安装node.js软件包管理器:

.. literalinclude:: ../../nodejs/startup/nodejs_dev_env/install_nvm
   :language: bash
   :caption: 安装nvm

- 通过nvm安装node.js:

.. literalinclude:: ../../nodejs/startup/nodejs_dev_env/nvm_install_nodejs
   :language: bash
   :caption: nvm安装node.js

