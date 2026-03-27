.. _helix_llm-ls:

=================================
Helix结合llm-ls实现AI辅助编程
=================================

.. _llm-ls:

llm-ls
=========

:ref:`hugging_face` 使用 :ref:`rust` 开发了一个 `huggingface/llm-ls <https://github.com/huggingface/llm-ls>`_ ，提供基于LLM来实现的LSP服务器，负责将编辑器的补全请求发送给 :ref:`ollama` 等后端。

llm-ls提供的功能:

- Prompt(提示): 使用当前文件作为上下文生成提示，根据需求可以选择是否使用"fill in the middle" (中间填充)
- Telemetry(遥测): 收集有关请求和补全的信息，以便进行重新训练(llm-ls除了查询模型API时设置用户代理外，所有数据都存储在日志文件 ``~/.cache/llm_ls/llm-ls.log`` 中，所以不会有数据泄露隐患。注意，日志级别设置为info)
- Completion(补全): llm-ls解析代码的抽象语法树(AST)，以确定补全应该死多行、单行还是空(不补全)
- 多种后端: 

  - Hugging Face's Inference API
  - Hugging Face's text-generation-inference
  - :ref:`ollama`
  - OpenAI compatible APIs (如 :ref:`llama-cpp-python` 提供模拟OpenAI API的web服务器`)

服务端
===========

.. literalinclude:: helix_llm-ls/docker_exec_qwen3
   :caption: 运行qwen3-coder

安装llm-ls
============

llm-ls官方GitHub只提供了 :ref:`windows` / :ref:`linux` 和 :ref:`macos` 的二进制程序，由于我目前使用 :ref:`freebsd` 作为桌面，所以我需要自己编译安装 ``llm-ls``

.. note::

   当在Helix中同时为一个语言(如Python)指定了 ``pyright`` 和 ``llm-ls`` 时，这两种LSP是同时运行的: Helix作为客户端，会同时向 ``pyright`` 和 ``llm-ls`` 发送请求，并实时合并它们的结果:

   - ``pyright`` 会根据源代码、类型定义、标准库文档来提供 **语法纠错、变量转跳、函数名提示** ，所给出的建议是 ""绝对正确的** (例如确定有这个方法)
   - ``llm-ls`` 是生成式AI，所以根据上下文"猜"下一步写什么，所以不仅能补全变量名，还能补全整行代码甚至一段逻辑，但是需要注意llm-ls给出的建议仅是 **看起来概率最高的** (不一定准确，甚至有幻觉)

FreeBSD安装llm-ls
------------------

- 在FreeBSD上安装 :ref:`rust` :

.. literalinclude:: ../../../rust/rust_startup/freebsd_install_rust
   :caption: 在FreeBSD上安装rust

- 下载源代码进行编译:

.. literalinclude:: helix_llm-ls/build_llm-ls
   :caption: 编译llm-ls

编译生成的二进制文件是 ``target/release/llm-ls`` ，将这个文件复制到 ``/usr/local/bin/`` 目录下

配置helix
==========

排查
=======

我在编辑 go 程序，发现没有出现 llm-ls 提示内容

由于 ``/usr/local/bin/llm-ls --help`` 显示只支持有限的参数:

.. literalinclude:: helix_llm-ls/llm-ls_help
   :caption: llm-ls支持的参数`
   :emphasize-lines: 5

所以尝试便携一个 ``/tmp/debug_llm.sh`` 脚本:

.. literalinclude:: helix_llm-ls/debug_llm.sh
   :language: bash
   :caption: 调试脚本 /tmp/debug_llm.sh

设置脚本可执行 ``chmod +x /tmp/debug_llm.sh``

然后修订 ``~/.config/helix/languages.toml`` 如下:

.. literalinclude:: helix_llm-ls/debug_languages.toml
   :caption: debug方式的 languages.toml

其他配置内容不变

此时helix报错也可以通过 ``cat /tmp/llm-ls.err`` 获得 ``llm-ls`` 崩溃前的最后输出

再次编辑 go 程序，我发现 ``~/.cache/helix/helix.log`` 显示 ``llm-ls`` 确实初始化失败:

.. literalinclude:: helix_llm-ls/helix_err.log
   :caption: helix.log 显示 llm-ls 服务器初始化失败

而 ``/tmp/llm-ls.err`` 居然提示是参数错误:

.. literalinclude:: helix_llm-ls/llm-ls.err
   :caption: 显示llm-ls因为参数错误退出

不过上述报错实际上是我配置文件问题，改正之后还是没有解决helix访问llm-ls问题

gemini提供了一个debug建议，采用FreeBSD的 :ref:`truss` :

.. literalinclude:: helix_llm-ls/truss
   :caption: 使用 truss 跟踪 llm-ls 系统调用

此时输入一些字符回车，程序会退出并打印出最后的系统调用(来查看问题所在)

.. literalinclude:: helix_llm-ls/truss_output
   :caption: 使用 truss 跟踪 llm-ls 系统调用
   :emphasize-lines: 2-8,10,12,13

日志中有密集的 ``_umtx_op(..., UMTX_OP_RW_WRLOCK, ...)`` 和 ``UNLOCK`` ，显示 ``llm-ls`` 的一部运行时(Tokio)在FreeBSD 15的Jail环境下，尝试获取读写锁时候陷入某种争用或异常。

gemini建议我为Jail设置 ``allow.sysvipc`` ，所以我尝试修改 ``/etc/jail.conf`` 添加:

.. literalinclude:: helix_llm-ls/jail.conf
   :caption: 设置 ``allow.sysvipc``
   :emphasize-lines: 3

我尝试设置后重启jail(实际上我是重启了操作系统)，但是依然没有解决llm-ls向 :ref:`ollama` 发送请求的问题(实际上根本没有发送请求)

此外，gemini还有一个建议是尝试限制 :ref:`rust` 程序的多线程，尝试用一个现成来避免死锁。也就是修订 ``~/.config/helix/languages.toml`` :

.. literalinclude:: helix_llm-ls/rust_threads_1_languages.toml
   :caption: 限制rust程序线程数量
   :emphasize-lines: 2,4

但是我实践发现并没有解决问题

.. note::

   **遗留问题**

   目前我没有解决 :ref:`freebsd` 通过 ``llm-ls`` 调用Ollsms来实现AI辅助编程，问题出在FreeBSD的客户端 ``llm-ls`` 没有能够发起调用。

   gemini推测可能是rust线程在FreeBSD上兼容的问题，我暂时没有时间继续排查。我准备先搞通Linux平台的AI辅助编程，至少 ``llm-ls`` 官方是支持Linux平台的，能够排除客户端不兼容的可能。

   待续...`

参考
=======

- `huggingface/llm-ls <https://github.com/huggingface/llm-ls>`_
