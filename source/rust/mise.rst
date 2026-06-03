.. _mise:

=========================
mise
=========================

`mise-en-place <https://mise.jdx.dev/>`_ 提供的开源软件 ``mise`` 为开发者提供了一个快速的环境就绪，免除了多语言开发工作者不要使用不同的软件版本管理工具来安装不同的开发语音的痛苦。网站上有一句话非常打动人心 ``You dev env, already prepped.``

``mise`` 使用Rust开发，能够管理 rust, python, ruby, node 等，将开发工具安装在用户的HOME目录，无需root权限，并且支持在不同项目中使用不同的开发语言版本，这对于需要维护不同环境的工作非常有利。

Docker环境不建议使用mise
=========================

我尝试在 :ref:`colima_images` 中融合了 ``mise`` 来安装我的开发环境，确实非常方便。不过，Dockerfile中不推荐 ``mise`` :

- 如果在云计算环境原生架构中， ``mise`` 的 ``shims`` 机制会切断 :ref:`nvim` 的LSP探测，也就是 ``mise`` 的环境加载脚本 ``eval "$(mise activate bash)"`` 可能会因为容器环境没有触发 ``.bashrc`` 而无法完成初始化。当然，交互情况下这个问题可以避免，但是部署到服务器无人操作时就存在不一致的隐患。
- ``mise`` 在容器内运行时，其下载、编译、缓存和软链接的目录全部杂糅在 ``/home/admin/.local/share/mise`` ，当通过 ``mise install XXX`` 安装是，后台下载庞大的源码、编译临时文件、校验包。这些临时垃圾会和最终的编译器一起死死地固化在同一个 Docker 镜像层（Layer）中，导致镜像体积不可控地暴增数 GB。
- 在Docker运行中推荐采用官方二进制包，这样每个 ``RUN`` 语句控制一层，修订版本只需要秒级增量构建；如果使用 ``mise`` 则版本变更会导致整个 ``mise`` 状态机重新计算，构建效率极低

:ref:`macos_studio` 建议使用mise
====================================

在MacBook Pro 本地系统上，项目五花八门，每个项目可能使用了不同的 Go / Python 版本，此时利用 ``mise`` 的 ``.mise.toml`` 能够控制随着项目目录自动、无感地切换环境版本，对于多项目并行开发非常优雅。

.. _mise_proxy:

mise代理
==========

mise的代理设置才用了类似 :ref:`curl` 的环境变量方式，我在 :ref:`colima_images` 构建时是用了socks5h代理

.. _mise_tmux:

在tmux中使用mise
===================

我在 :ref:`macos_studio` 中设置好 ``mise`` 之后，确实通过这个环境能够使用不同的开发工具，非常惬意。但是我发现一个奇怪的现象，就是当我使用 :ref:`tmux` 时，突然间 :ref:`ruby` 程序就回落到操作系统默认安装的 ``/usr/bin/ruby`` 而不是我通过 ``mise`` 安装的 ``~/.local/share/mise/installs/ruby/3/bin/ruby``

询问了gemini说明是:  **Tmux 默认的行为是启动一个“登录 Shell（Login Shell）”，而不是“交互式非登录 Shell（Interactive Non-login Shell）”**

也就是说 ``tmux`` 新建一个会话时，会在后台fork 出一个新的 Zsh 进程。为了保证环境的“纯净”，tmux 默认会把它当作 Login Shell 来初始化。

解决的方法: 修改 ``~/.tmux.conf`` ，迫使tmux表现得像一个规规矩矩的普通终端子窗口，不要每次都去拉取 Login Shell

.. literalinclude:: mise/tmux.conf
   :caption: ``~/.tmux.conf`` 配置启用普通交互式non-login shell

需要注意的时，此时即使重启终端，重新进入 ``tmux`` 该设置也 :strike:`不一定` 很可能不生效，原因是 **虽然重启了终端窗口，但 Tmux 的后台守护进程（Server）在 macOS 内存里其实根本没有退出** 执行tmux 时，它只是拉起了一个新的客户端（Client），去连接那个依然携带着旧配置、旧环境中旧 $PATH 的后台老进程。

解决方法是彻底杀掉系统中 ``tmux`` 服务进程:

.. literalinclude:: mise/restart_tmux
   :caption: 彻底重启tmux
