.. _vscode_extensions:

=====================
VS Code扩展
=====================

.. note::

   参考gemini建议结合实际实践整理

通用插件(跨语言卡肺癌)
========================

- ``GitLens`` : 深度集成 Git 历史、Blame 追溯和代码修改行上下文。软件核型功能免费使用，应该已经足够，Pro版本需要收费。另外虽然首次使用会引导登录，但实际使用不需要登录。
- ``Continue`` : 本地 AI 辅助插件 :ref:`vscode_continue_ollama` 开源LLM能够帮助分析代码提供review以及建议
- ``vim`` : :ref:`vscode_vim` 类模拟插件可以保持和Linux服务器开发的一致性体验，持续训练保持肌肉记忆。
- ``Todo Tree`` : 全局高亮和扫描代码中的 ``TODO`` / ``FIXME``

Python 专属开发栈
===================

- ``Python`` (Microsoft): 官方核心插件，提供基础语法高亮与虚拟环境识别。
- ``Pylance`` ：基于 Microsoft Pyright 的超快静态类型检查器，支持智能感知、跳转和类型推导。
- ``Ruff`` (Astral): 用 Rust 编写的超高速 Python Linter 和 Formatter（集成了 Flake8、isort、Black 的绝大部分功能），速度比传统工具快几个数量级。

Go 专属开发栈
===============

- ``Go`` (Go Team at Google): 官方插件，自动管理底层工具链( ``gopls`` 、 ``dlv`` 等)。
- 核心底层工具(通常在装完 Go 插件后由其自动提示安装)

  - ``gopls`` : 官方 Language Server，提供极其强大的 Go 语言自动补全、重构和类型检查。
  - ``golangci-lint`` : 业界最权威的 Go 代码静态检查聚合器。

保存时自动格式化(Format on Save)
===================================

建议在 ``.vscode/settings.json`` 中配置保存时自动格式化(Format on Save):

.. literalinclude:: vscode_extensions/vscode_settings.json
   :language: json
   :caption: 配置VSCode保存时自动格式化(Format on Save)

调试配置
==============

Go 调试:Go 插件自带强大的 Delve（dlv）调试器支持。在项目根目录下生成 ``.vscode/launch.json`` :

.. literalinclude:: vscode_extensions/vscode_launch.json
   :language: json
   :caption: 配置VSCode调试器支持

Python 调试:配合 Pylance 与内置调试器，支持无缝断点调试多线程、异步（Asyncio）协程以及 FastAPI 服务。

参考
========

- `My Must-Have VS Code Extensions and Settings <https://blog.nathanv.me/posts/vs-code-extensions/>`_
- `5 Best VS Code Themes <https://lightrun.com/5-best-vs-code-themes/>`_
- gemini
