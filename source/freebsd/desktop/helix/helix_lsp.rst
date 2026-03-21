.. _helix_lsp:

===========================================
Helix结合LSP(Language Server Protocol)
===========================================

.. note::

   本文基于gemini建议进行实践，虽然完成初始配置，但有可能并非准确和最优，有待后续继续实践。

   由于没有按照 :ref:`helix_lfs` (按照官方文档实践)，所以可能并不完善。我准备后续再继续实践，目前先以本文方法继续学习。

和 :ref:`vim` / :ref:`nvim` 不同，Helix对大多数主流语言，内置了"对接协议"，所以只需要将LSP程序安装到系统的 ``$PATH`` 中，Helix就能够自动识别并"握手成功"。也就是说，几乎无需配置，开箱即用。

Helix在源码中内置了一个 ``language.toml`` 默认文件，在这个文件中，已经为数百中编程语言定义好了"标准配置"。当你在系统中安装好了 ``py-pyright`` 或 ``gopls`` 之后，LSP程序位于 ``/usr/local/bin`` 。当使用Helix打开对应文件，如 ``.py`` 或 ``.go`` 文件，Helix就会自动扫描 ``$PATH`` ，发现对应的LSP程序，自动开启语法高亮，转跳定义和错误诊断。

安装LSP
=========

python+yaml+ansible
---------------------

- 先安装node.js，当前安装24.13.0(LTS)，实际版本以pkg search node和node.js官网为准

.. literalinclude:: ../../../nodejs/startup/nodejs_dev_env/freebsd_install_node
   :caption: 在FreeBS上使用pkg安装

- 安装基于node的LSP

.. literalinclude:: helix_lsp/install_npm_lsp
   :caption: 安装基于node的LSP

.. literalinclude:: helix_lsp/install
   :caption: 安装基于node的LSP

- 由于我也使用 :ref:`ansible` ，所以先安装ansible，然后再配置helix能够解析ansible语法

.. literalinclude:: ../../../devops/ansible/freebsd_ansible/install
   :caption: 安装Ansible

检查LSP是否安装成功:

.. literalinclude:: helix_lsp/health
   :caption: 检查LSP

这里提示信息有一些错误:

.. literalinclude:: helix_lsp/health_output
   :caption: 检查LSP时输出信息

这里 ``python`` 相关的 LSP 工具如下:

.. csv-table:: LSP核心工具对比
   :file: helix_lsp/python_lsp.csv
   :widths: 20,20,30,30
   :header-rows: 1

Helix使用 :ref:`rust` 开发，所以对Ruff支持非常丝滑，Ruff不仅能告诉你代码哪里写得不规范(如未使用的变量)，还能一键修复。Pyright是微软的VS Code团队维护，对复杂的库(如 :ref:`pytorch` , NumPy, :ref:`rocm` 相关库)有极佳的自动补全支持。

建议同时启用 ``Pyright+Ruff`` ，所以先安装 ``py311-ruff`` :

.. literalinclude:: helix_lsp/install_ruff
   :caption: 安装ruff

另外，针对yaml LSP建议同时安装ansible-language-server方便编辑 :ref:`ansible` 的特殊YAML:

.. literalinclude:: helix_lsp/ansible_lsp
   :caption: 安装ansible-language-server 
 
- 最后，综上完成配置 ``~/.config/helix/languages.toml`` :

.. literalinclude:: helix_lsp/languages.toml
   :caption: 配置 ``~/.config/helix/languages.toml``
   :language: toml

注意，虽然上述配置已经完成，但是 ``hx --health ansible`` 还是有一些报错:

.. literalinclude:: helix_lsp/hx_health_ansible_output
   :caption: ansible相关的hx报错
   :emphasize-lines: 8-10

这是FreeBSD中Helix的 ``runtime`` 文件缺失或路径不匹配导致的。在Helix中， ``Hightlight`` , ``Textobject`` , ``Indent`` 这些功能依赖于对应的 ``.scm`` 查询文件。由于这里手动定义了 ``scope = "source.ansible"`` ，但是FreeBSD的 ``pkg`` 安装路径中可能没有安装 ``ansible`` 的查询文件。

由于ansible本质上是YAML，所以最快且最稳妥的方法是将YAML的查询文件"借"给ansible使用:

.. literalinclude:: helix_lsp/fix_ansible_helix
   :caption: 修复ansible查询文件

go
------

- 安装 ``gopls`` :

.. literalinclude:: helix_lsp/go
   :caption: 安装 ``gopls```

- 此时检查 ``hx --health go`` 有如下提示:

.. literalinclude:: helix_lsp/go_health_output
   :caption: 检查go环境有部分报错
   :emphasize-lines: 3,5

这里 ``dlv`` 是调试工具，可以在Helix中设置断电、单步执行代码，所以补充安装 ``delve`` :

.. literalinclude:: helix_lsp/fix_golangci-lint`
   :caption: 修复 golangci-lint 报错

这里 ``go install`` 需要访问github.com，所以需要 :ref:`go_proxy` :

.. literalinclude:: ../../../golang/go_proxy/socks_proxy
   :language: bash
   :caption: 设置go socks代理

需要注意，通过 ``go install`` 安装的二进制软件位于 ``~/go/bin`` 目录，所以需要添加到环境变量中以确保能够找到 ``golangci-lint-langserver`` 命令:

.. literalinclude:: helix_lsp/go_path
   :caption: 设置GO程序路径

完成上述安装配置之后，再次执行 ``hx --health go`` 就能看到正确的设置:

.. literalinclude:: helix_lsp/go_health_output_ok
   :caption: 正确的设置输出信息

rust
-------

- 安装 :ref:`rust` :

.. literalinclude:: ../../../rust/rust_startup/freebsd_install_rust
   :caption: 在FreeBSD上通过pkg安装rust

- 安装LSP:

.. literalinclude:: helix_lsp/rust
   :caption: 安装rust的LSP
