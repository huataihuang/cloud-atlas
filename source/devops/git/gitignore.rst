.. _gitignore:

========================
.gitignore配置
========================

.. note::

   本文记录gemini提供的 ``.gitignore`` 模板文件，以备参考

在 :ref:`macos` 环境下开发 Python、Ruby、Go、Node.js、Rust、Swift、Neovim/Vim 设置 ``.gitignore`` 配置文件 ``~/.gitignore_global`` :

.. literalinclude:: gitignore/gitignore_global
   :caption: 全局 ``.gitignore`` 模板: ``~/.gitignore_global``

说明
=====

- 精确过滤 macOS 隐藏垃圾：不仅包含了 ``.DS_Store`` ，还涵盖了 Apple 系统在卷（Volume）或移动硬盘上生成的 ``.Trashes`` （回收站）、 ``.Spotlight-V100`` （索引）以及 ``._*`` （资源分叉文件）。

- 工具链与缓存隔离：自动屏蔽 Python 的 ``__pycache__`` / ``.ruff_cache`` ，Go 编译的二进制文件及 ``.out`` ，Ruby 的 ``.bundle`` / ``vendor`` ，以及 Neovim 的临时 ``.swp`` / ``.un~`` 撤销文件。

- 安全防泄漏：全局拦截 ``.env`` 、 ``*.key`` 和 ``*.pem`` 等敏感密钥文件，防止因一时疏忽将机密信息提交到 GitHub / GitLab 公开仓库。

- Rust 安全隔离

  - 自动屏蔽 Rust 的构建产物目录 ``target/`` 。Rust 在频繁编译时 ``target/`` 目录动辄占用数 GB 空间，全局屏蔽可以彻底规避误将编译缓存推送到 GitHub 的尴尬。
  - 屏蔽 ``*.rlib`` 和 ``*.rmeta`` 等二进制中间库文件以及某些编辑器插件生成的备份文件（ ``*.rs.bk`` ）。

- Swift & Xcode 专业规则

  - 屏蔽 Xcode 专有的用户个人状态（ ``xcuserdata/`` ，包含了你个人在 Xcode 里打的断点、展开的目录状态等，绝对不应该提交）。
  - 过滤 Swift Package Manager (SPM) 编译产生的 ``.build/`` 和 ``.swiftpm/`` 缓存文件夹。
  - 精确保留了 Xcode 共享项目结构定义（ ``project.pbxproj`` 和 ``xcshareddata`` ），保证如果以后创建了 Swift/macOS App 团队协作项目，共享的核心结构依然能正常被 Git 追踪。

参考
=====

- gemini
