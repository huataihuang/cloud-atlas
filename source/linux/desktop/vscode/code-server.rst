.. _code-server:

==================================
coder-server: 浏览器中运行VS Code
==================================

开源社区通过逆向工程，基于VS Code的全开源版本(Code-OSS)构建了 ``code-server`` ，重新实现了一套Web包装层，绕过了微软的私有运行环境限制。所以，现在使用MIT开源协议的 :ref:`code-server` 可以被 :ref:`kubernetes` 编排，实现一人一个Pod，每个Pod跑一个 :ref:`code-server` 实现云开发环境。

.. csv-table: ``code-server`` vs. ``VS Code Server``
   :file: code-server/code-server_vs_vscode_server.csv
   :widths: 20,40,40
   :header-rows: 1

参考
========

- `github code-server <https://github.com/coder/code-server>`_
- `基于树莓派部署 code-server <https://juejin.cn/post/7039200743114407944>`_
- `Websoft9(网久软件)提供的code-server部署运维手册 <https://support.websoft9.com/docs/codeserver/zh/>`_
