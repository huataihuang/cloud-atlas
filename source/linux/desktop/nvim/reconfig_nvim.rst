.. _reconfig_nvim:

==========================
重新配置nvim
==========================

很久以前，我配置nvim采用了复杂的配置方法，浪费了很多时间精力。我现在采用 :ref:`nvim_lightweight_ide` 快速完成，所以对之前的配置进行清理，重新完成配置。

需要清理 3 个核心目录:

- 配置文件目录
- 插件缓存/安装目录
- 状态与数据目录

清理配置
==========

执行以下命令，清空所有相关的临时文件和配置

.. literalinclude:: reconfig_nvim/clean
   :caption: 清理旧nvim和lazyvim

确保 :ref:`mise` 管理的 Neovim 依然可以正常响应，且此时它应该退回到了最原始的无配置状态:

.. literalinclude:: reconfig_nvim/check
   :caption: 查看nvim版本

打开 ``nvim`` ，此时应该看不到任何 LazyVim 的界面或报错，只是一个非常干净的纯文本编辑器。

重新配置
===========

按照 :ref:`nvim_lightweight_ide` 重新配置
