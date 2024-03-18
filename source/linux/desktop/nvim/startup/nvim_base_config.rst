.. _nvim_base_config:

====================
Neovim基础配置
====================

init.lua
==============

在 ``~/.config/nvim/`` 目录下配置初始配置文件 ``init.lua`` :

.. literalinclude:: nvim_base_config/init.lua
   :caption: 在 ``~/.config/nvim/init.lua`` 中配置初始设置

上述初始配置设置了一些neovim的常用编辑特性，例如tab默认4个空格等

要进一步配置 neovim ，需要安装插件，我将采用 :ref:`lazy.nvim` 来实现插件管理，请参考 :ref:`lazy.nvim_startup` 安装插件案例

vim内部变量
-------------

使用元访问器可以更直观地操作内部变量：

- vim.g: 全局变量
- vim.b: 缓冲区变量
- vim.w: 窗口变量
- vim.t: 选项卡变量
- vim.v: 预定义变量
- vim.env: 环境变量



参考
===========

- `neovim入门指南(一)：基础配置 <https://www.cnblogs.com/youngxhui/p/17730419.html>`_
