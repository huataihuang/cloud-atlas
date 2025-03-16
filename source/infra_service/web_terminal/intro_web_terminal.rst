.. _intro_web_terminal:

==========================
Web Terminal简介
==========================

和 :ref:`guacamole` 使用HTML5方式完整输出操作系统图形桌面不同， Web Terminal专注于终端模拟器输出，用于在浏览器中远程和系统交互。这对于 :ref:`linux` 系统管理员和 :ref:`devops` 来说非常重要的功能，有不少开源解决方案值得探索。

- :ref:`xtermjs` : 该开源项目是众多Web Terminal的 **核心** 和基础，提供了基本的终端模拟功能，但是实际使用通常会使用第三方集成工具，例如 :ref:`kubebox`
- :ref:`webssh` : 使用Python开发的基于 :ref:`xtermjs` 实现的简单 Web Terminal工具，适合个人使用
- :ref:`kubebox` : :ref:`kubernetes` 中部署终端服务用于使用 :ref:`kubectl` 等工具以及使用 :ref:`` 监控集群，同样基于 :ref:`xtermjs` 实现

参考
======

- `16 Open-source free Self-hosted Web-based Terminals <https://medevel.com/16-list-self-hosted-terminals/>`_ 很多项目已经停止开发，我没有一一验证，目前仅尝试我所了解的几个
- `How to create web-based terminals <https://dev.to/saisandeepvaddi/how-to-create-web-based-terminals-38d>`_ 一个非常好的解决方法，结合 :ref:`xtermjs` 和 :ref:`socketio` 实现WEB terminal
