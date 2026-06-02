.. _macos_studio:

==================
macOS工作室
==================

在 :ref:`macos_studio_startup` 我思考了不同的构建工作室的基础环境，例如虚拟化和容器化。我个人一直在不同的Linux环境和macOS环境中切换(有太多的设备和安装部署)，每次起步初始化确实也花费了不少时间。例如我有机会能短暂使用 :ref:`apple_silicon_m1_pro` ，但是很快又得切换回 :ref:`arch_linux` 的 :ref:`mbp15_late_2013` 。

理想的工作方式是全面采用容器化技术( :ref:`docker` )来构建，并结合 :ref:`kind` 模拟 :ref:`kubernetes` ，这样在不同的工作环境中，只要采用合适的镜像( :ref:`dockerfile` )以及基础运行环境，就能够无缝切换。

2026年6月，我通过 :ref:`oclp_macos` 复活了我的古老的 :ref:`mbp15_late_2013` ，并且折腾了 :ref:`colima_nfs` 来实现一个完整的准高性能 :ref:`debian_tini_image` 。不过，硬件还是太古早了，我想要更为清晰分工的开发环境和服务器环境，而不是全部堆积在本地笔记本上无法拆分。所以，我参考现在现代互联网大厂的标准开发工作，来实现自己个人的开发、测试、部署环境:

- 采用 :ref:`mise` 构建本地开发环境，日常开发在本地 macOS 中完成
- 项目采用Dockerfile封装，通过 :ref:`git` 提交到 :ref:`gitlab` 中触发自动化 :ref:`linux` 测试环境部署
- 采用自动测试工具进行代码覆盖测试
- 通过测试后采用 :ref:`argo` 自动部署到生产环境

:ref:`homebrew`
==================

要实现完整的可移植工作环境(和 :ref:`linux` 对齐)，在macOS环境中使用 :ref:`homebrew` 来构建基础环境:

- 安装 homebrew :

.. literalinclude:: homebrew/install_homebrew
   :language: bash
   :caption: 通过网络安装Homebrew

- 安装 :ref:`mise` :

.. literalinclude:: homebrew/install_mise
   :caption: 安装mise

- 使用mise安装开发工具链:

.. literalinclude:: macos_studio/brew_install_dev 
   :caption: 通过mise来安装开发工具

- 克隆 LazyVim Starter 骨架:

.. literalinclude:: macos_studio/lazyvim
   :caption: 克隆 LazyVim Starter 骨架

- 为避免GUI客户端或者终端启动时没有正确加载 ``~/.zshrc`` ，这里添加 :ref:`nvim` 入口配置，确保补全 ``mise`` 的二进制路径: 修改 ``~/.config/nvim/config/options.lua`` :

.. literalinclude:: macos_studio/options.lua 
   :caption: ``~/.config/nvim/lua/config/options.lua`` 添加环境变量- 

- 首次启动nvim， ``lazy.nvim`` 插件管理器会自动拉取上百个 LazyVim 生态的核心 Lua 脚本。这里依赖前面 ``options.lua`` 中设置的PATH，neovim会通过 ``~/.local/share/mise/shims`` 识别到本地安装的 ``go`` , ``cargo`` , ``python3``

在macOS本地无需执行headless编译，可以在UI界面中静静等待它下载完成

不过，这里还是推荐如 :ref:`colima_images` 类似的静默方式命令行安装 ``+Lazy! sync`` 和 ``+TSUpdateSync`` 来完成 Lazy.nvim + Treesitter（语法高亮)安装:

.. literalinclude:: macos_studio/lazy.nvim_treesitter
   :caption: 静默安装 ``+Lazy! sync`` 和 ``+TSUpdateSync``

- 插件下载完毕后，执行以下命令安装LSP

.. literalinclude:: macos_studio/mason
   :caption: 通过Mason安装本地需要的LSP

这里安装的LSP还需要激活:

在nvim中输入 ``:Mason`` 并回车，看到 ``Installed`` 中如果 clangd、rust-analyzer、gopls、pyright、ruff 以及 ruby-lsp 都有了绿色的 ``[i]`` 标记则表示已经完成全量热态注册

输入 ``:LazyExtras`` LazyVim 骨架，确保你开启了对应语言的 lang 扩展: 找到 lang.go、lang.rust、lang.python 等，按下 x 键激活它们。激活后，LazyVim 才会真正去调度刚刚安装好的 Mason 二进制专家。

我这里遇到过一个报错:

.. literalinclude:: macos_studio/link_error
   :caption: 软链接报错

这个问题似乎是因为没有设置好GOPATH，并且默认的 ``~/go/bin`` 目录不存在。因为使用了 :ref:`mise` ，所有的GO安装软件都在 ``~/.local/share/mise/installs/go/1.26.3/bin/`` 

而Mason需要将执行程序复制到 ``~/.local/share/nvim/mason/packages/`` 目录下对应模块的目录下，也就是 ``goimports`` 应该复制到 ``~/.local/share/nvim/mason/packages/goimports/goimports`` 目录下对应模块的目录下

所以我先手工安装 ``goimports`` 和 ``gofumpt`` :

.. literalinclude:: macos_studio/install_goimports_gofumpt
   :caption: 手工安装 goimports / gofumpt

此时可以在 ``~/.local/share/mise/installs/go/1.26.3/bin/`` 目录下找到编译安装的2个执行文件，现在把它们复制到Mason对应packages目录:

.. literalinclude:: macos_studio/cp_goimports_gofumpt
   :caption: 按照Mason的packages目录复制 goimports 和 gofumpt

然后在补齐配置和软连接:

.. literalinclude:: macos_studio/link_goimports_gofumpt
   :caption: 然后在补齐配置和软连接

此时再进入 ``nvim`` 并使用 ``:Mason`` 就会看到安装的这两个language模块成功了。

.. note::

   这里还有一点问题是在 ``:Mason`` 面板总是提示 ``gomiports`` 和 ``gofumpt`` 需要版本升级::

      new version available: - -> v0.10.0
      new version available: - -> v0.45.0

   但实际上已经安装好，就是不知道是哪里修复这个版本信息，看起来gemini提供的 ``mason-receipt.json`` 是正确的，但似乎还有什么隐含的配置未修复

- macOS 自带的 Xcode 命令行工具里已经内置了 ``sourcekit-lsp`` 只需要在 Neovim 里告诉 LazyVim 顺着系统路径去调用它即可: 创建 ``~/.config/nvim/lua/plugins/swift.lua`` :

.. literalinclude:: macos_studio/swift.lua
   :caption: 创建 ~/.config/nvim/lua/plugins/swift.lua

- 安装必要工具(可选):

.. literalinclude:: homebrew/brew_install
   :language: bash
   :caption: 在macOS新系统必装的brew软件

- 切换python3版本:

.. literalinclude:: homebrew/switch_python3_to_homebrew_version
   :language: bash
   :caption: 切换macOS的python3版本到homebrew提供的版本

:ref:`virtualenv` 和 :ref:`sphinx_doc`
=========================================

- 结合 :ref:`sphinx_doc` 同时安装和部署好 :ref:`virtualenv` :ref:`python` 开发环境

虚拟沙箱环境非常简单:

.. literalinclude:: ../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: ../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

- 安装Sphinx 以及 rtd :

.. literalinclude:: ../../devops/docs/write_doc/install_sphinx_doc
   :language: bash
   :caption: 通过virtualenv的Python环境安装sphinx doc


:ref:`lima` 虚拟化
====================

.. note::

   我的 :ref:`mbp15_late_2013` 硬件非常古老，通过 :ref:`oclp_macos` 实现准新的 macOS 15运行已经非常消耗资源，所以再运行虚拟化和 :ref:`kubernetes` 模拟虽然可以实现，但使用效率不高。

   我这里仅记录我的折腾笔记，后续我实际上会采用更为轻量级的本地运行开发环境，而将重负载的Linux虚拟机全部迁移到服务器上运行。

:ref:`kubernetes` 模拟
===========================

.. note::

   另一个方案是自己构架虚拟化环境，也就是不依赖于 :ref:`install_docker_macos` 获得 Hypervisor 款里框架，而是手工通过 :ref:`lima` 构建虚拟机。这样更好玩，更有技术挑战。

- 通过 :ref:`homebrew` :ref:`install_docker_macos` :

.. literalinclude:: ../../docker/desktop/install_docker_macos/brew_install_docker
   :language: bash
   :caption: 通过Homebrew安装Docker Desktop for macOS

- 安装 :ref:`kind` :

.. literalinclude:: ../../kubernetes/kind/kind_startup/brew_install_kind
   :language: bash
   :caption: 在macOS平台上安装kind

- 3个管控节点，5个工作节点的集群，并且结合本地registry，采用 :ref:`kind_local_registry` 方法 ``kind-with-registry-macos.sh`` 脚本:

.. literalinclude:: ../../kubernetes/kind/kind_local_registry/kind-with-registry-macos.sh
   :language: bash
   :caption: 运行Registry适配kind集群(dev)，macOS环境的Docker Desktop for macOS

- 需要 :ref:`fix_kind_restart_fail` ，所以再执行:

.. literalinclude:: ../../kubernetes/kind/fix_kind_restart_fail/kind_static_ips.sh
   :language: bash
   :caption: 通过 kind_static_ips.sh 脚本设置kind集群每个node静态IP
