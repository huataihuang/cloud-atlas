.. _macos_nvim_alias:

=======================
macOS中设置nvim alias
=======================

macOS和Linux不同，没有 ``/etc/alternatives`` 来管理命令软链接的标准，并且 ``/usr/bin/vi`` 和 ``/usr/bin/vim`` 是受系统完整性保护(SIP, System Integrity Proteciton)锁死的二进制文件，所以即使有 ``root`` 权限也不能直接rm ``/usr/bin`` 目录下文件以及添加软链接。

比较简洁且优雅的方式是采用Shell运行时劫持，针对zsh修订 ``~/.zshrc`` :

.. literalinclude:: macos_nvim_alias/zshrc
   :caption: 配置 ``~/.zshrc`` 添加nvim的alias

说明:

- ``if command -v nvim`` 判断，即使系统没有通过 :ref:`homebrew` 安装了 :ref:`nvim` ，也能够平滑回退到系统原生的 ``vi``
- 补全对齐：使用 ``comdef`` 劫持zsh的补全树，这样在终端输入 ``vi [Tab]`` 能够跳出的高亮补全菜单完全走 ``nvim`` 的逻辑

  - ``comdef`` 是zsh内置的高级补全系统(Completion System)提供的一个核心函数，但是如果补全引擎(compinit)没有加载的话，会不能识别 ``compdef`` 关键字，所以这里增加一个判断 ``compdef`` 是否加载并初始化

参考
======

- gemini
