.. _antora_quickstart:

=========================
Antora快速起步
=========================

安装 :ref:`nodejs`
====================

Antora是运行在Node.js的JavaScript运行环境中，可以运行在Linux,macOS和Windows。最小化情况下，Antora可以运行在 :ref:`debian` stable提供的Node.js版本上。但是官方建议使用Node.js标记 **Active** 的LTS版本。当前对于Antora 3.2.x发行版，建议使用Node.js v24。

我的实践在 :ref:`oclp_macos` 上运行 macOS 15，采用 :ref:`mise` 安装 :ref:`nodejs` ，安装完成后检查版本:

.. literalinclude:: antora_quickstart/node_version
   :caption: ``node`` 版本

另一种常用的安装Node.js的方式是使用 :ref:`nvm`

安装Antora
============

要通过Antora生成文档网站，需要Antora命令行工具和Antora网站生成器。

首先创建一个名为 ``docs-site`` (该名字按需设置)，并进入目录

.. literalinclude:: antora_quickstart/mkdir
   :caption: 创建目录

初始化 ``package.json`` 并在playbook项目中安装需要的packages，这样就能够使用 ``npx`` 命令来运行 ``antora`` :

.. literalinclude:: antora_quickstart/antora
   :caption: 初始化antora

.. note::

   这里没有使用 ``npm init -y`` 以避免在文件中产生必要的key，后续采用直接编辑 ``package.json``

高危漏洞提示和处理
--------------------------------

当执行 ``npm i -D -E antora`` 会看到一长串提示信息:

.. literalinclude:: antora_quickstart/antora_output
   :caption: 初始化antora提示信息
   :emphasize-lines: 6

这里有一个警示 ``9 high severity vulnerabilities`` (9 个高危安全漏洞)。不过，在Antora这个特定的使用场景下， **几乎没有危险** :

- npm 的官方数据库（GitHub Advisory Database）记录了历史上所有被通报过的漏洞。当 npm 下载某个依赖包时，如果匹配到了数据库中已知的 CVE 或 Vulnerability 记录，就会弹出警告。
- Antora 作为一个复杂的静态网站生成器，底层依赖了非常多社区的包（例如解析 AsciiDoc 的引擎、处理文件路径的工具、HTML 生成库等）。某些深层依赖包可能很久没有发布新版本，或者被标记了存在某种漏洞（比如：正则拒绝服务攻击 ReDoS、开发阶段的任意代码执行）。

但是，对于Antora而言，Antora 是一个 **构建期工具(Build-time Tool)** ，它只在执行 ``npx antora`` 编译文档时运行，生成一堆纯 ``HTML/CSS/JS`` 静态文件。这些带有漏洞的 npm 包代码完全不会部署到生产环境的 Nginx 或 Web 服务器中。生产环境暴露给用户的仅仅是生成的 ``静态文件`` ， **没有任何 Node.js 运行时** 。

- 查看具体漏洞:

.. literalinclude:: antora_quickstart/audit
   :caption: 在项目目录下运行 ``npm audit``

该命令会列出具体的高危漏洞、属于啊几个依赖包以及漏洞的类型。

- 运行以下命令让npm自动升级存在漏洞且兼容的次版本包:

.. literalinclude:: antora_quickstart/fix
   :caption: 尝试自动修复

.. note::

   切勿盲目使用 ``npm audit fix --force`` 。因为 ``--force`` 会强行升级大版本（Major Version），这可能会破坏 Antora 内部依赖的兼容性，导致 ``npx antora`` 无法正常运行。

   如果在运行 ``npm audit fix`` 后，依然提示存在部分高危漏洞（说明 Antora 官方还没有适配最新版依赖，或者上游包尚未修复），完全不需要理会它。

   在 JavaScript/Node.js 生态中，对于这类仅用于构建静态内容的开发工具( ``-D`` 安装的 DevDependencies)，只要构建能正常通过，就可以忽略这类警告。

验证和运行
------------

- 执行以下命令验证antora

.. literalinclude:: antora_quickstart/version
   :caption: 验证antora

输出可以看到antora的版本

.. literalinclude:: antora_quickstart/version_output
   :caption: 验证antora版本输出信息

- 要升级Anotra，则更新 ``package.json`` 中的antora包的版本号，然后再次运行 ``npm i`` 命令

- 也可以将 ``antora`` 命令安装到 ``PATH`` 中，这样就是全局化安装Antora:

.. literalinclude:: antora_quickstart/install_global
   :caption: 全局化安装Antora

不过还是强烈建议将Antora安装在playbook项目中而不是全局安装。这种本地化安装Antora可以方便管理Antora的版本。

使用远程源创建playbook
========================

要创建一个文档网站，Antora需要一个playbook。最简单的使用Antora是将playbook指向一个远程仓库中的现有文档。例如，使用 `Antora demo repositories <https://gitlab.com/antora/demo>`_ 的内容源。

- 创建一个 ``antora-playbook.yml`` :

.. literalinclude:: antora_quickstart/antora-playbook.yml
   :caption: ``antora-playbook.yml``
   :language: yaml
   :emphasize-lines: 3,5,11

``component`` 版本用于作为网站的home页面

``sources`` 分类包含了 :ref:`git` 仓库位置，分支及其他仓库属性

``ui`` 分类包含了UI bundle的位置以及如何处理

运行Antora
============

通过将 ``antora`` 命令指向playbook文件来生成网站:

.. literalinclude:: antora_quickstart/run
   :caption: 生成网站

输出显示:

.. literalinclude:: antora_quickstart/run_output
   :caption: 生成网站输出信息

这里可以看到Antora会clone出 ``content`` 和 ``UI`` 仓库，并生成文档网站输出到默认的输出目录，并且在终端中输出了该目录的文件URL。

按照提示访问生成的网站文件，就能看到一个demo网站，提供了文档类网站常用的导航(产品和服务)以及文档版本选择。

需要注意，上述 ``npx antora antora-playbook.yml`` 还有一个推荐参数 ``--fetch`` :

.. literalinclude:: antora_quickstart/run_fetch
   :caption: 使用 ``--fetch`` 参数

这个 ``--fetch`` 参数非常关键，表示 ``强制从远程 Git 仓库更新/拉取最新的文档源码和 UI Bundle`` :

.. csv-table:: ``npx antora`` 是否使用 ``--fetch`` 参数的对比
   :file: antora_quickstart/antora_fetch.csv
   :widths: 20,40,40
   :header-rows: 1

使用本地源创建playbook
========================

Antora也支持本地内容源，也就是在当前主机clone或初始化，也就是在本地仓库创建站点这样既包含playbook也包含内容源(既实际网站)。可以将所有内容都存放在当前项目目录而无需依赖任何远程git仓库。

举例，这里在本地git仓库初始化网站内容

.. literalinclude:: antora_quickstart/init
   :caption: 初始化网站内容

如果已经在本地仓库存有内容，则上一步骤不需要。

- 接下来创建标准化目录结构来存储一系列页面，导航文件以及内容源根的组件版本描述。这个内容源的根可以存放在一个以 ``docs`` 开始的目录
 
参考
========

- `Install and Run Antora Quickstart <https://docs.antora.org/antora/latest/install-and-run-quickstart/>`_
