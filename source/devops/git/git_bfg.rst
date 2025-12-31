`BFG Repo-Cleaner <https://rtyley.github.io/bfg-repo-cleaner/>`_ 是一个 ``git-filter-branche`` 的简单但快速的替代工具，可以清理Git仓库中误提交的垃圾数据。

.. note::

   以下实践在 :ref:`alpine_linux` 上完成

- 安装OpenJDK LTS 17 JRE运行环境(在服务器上可以节约空间):

.. literalinclude:: git_bfg/install_jre
   :caption: 安装 OpenJDK LTS 17 JRE运行环境

- 补充步骤?：由于需要清理掉 ``build/`` 目录，所以需要先修改 ``.gitigore`` ，去掉这个限制，否则后续 ``git push`` 会提示 "Everything is update" ，也就无法完成远程仓库清理

- 由于BFG默认不修改最后一次提交的内容，所以当前仓库中的 ``build/`` 目录需要首先移除并提交仓库，否则执行后续BFG没有效果::

   git rm -r --cached build/
   git commit -m "Remove build directory before cleaning history"
   git push

- 采用 :strike:`mirror` ``bare`` 方式clone出仓库

.. literalinclude:: git_bfg/git_clone
   :caption: 采用bare方式clone出仓库

上述 ``--mirror`` 参数的 ``git clone`` 表示是一个bare repo，也就是常规文件不可见，但是完整复制仓库的Git数据库。在这个基础上可以完整备份整个仓库而不会丢失数据。

上述命令执行之后，在本地出现一个 ``cloud-atlas.git`` 目录，但是在这个目录下没有原来仓库中的常规文件，而是类似数据库结构，在目录下是如下内容::

   $ ls -lh cloud-atlas.git
   total 32K
   -rw-r--r-- 1 admin admin   23 Dec 30 01:55 HEAD
   -rw-r--r-- 1 admin admin  193 Dec 30 01:53 config
   -rw-r--r-- 1 admin admin   73 Dec 30 01:53 description
   drwxr-sr-x 2 admin admin 4.0K Dec 30 01:53 hooks
   drwxr-sr-x 2 admin admin 4.0K Dec 30 01:53 info
   drwxr-sr-x 4 admin admin 4.0K Dec 30 01:53 objects
   -rw-r--r-- 1 admin admin 2.6K Dec 30 01:55 packed-refs
   drwxr-sr-x 4 admin admin 4.0K Dec 30 01:53 refs

- 现在可以执行以下命令 **标记** 原先误提交到仓库的 ``build/`` 目录需要清理(注意文件还物理存在于Git的对象库，所以后面还需要执行Git的垃圾回收命令来释放空间)::

   java -Xms128m -Xmx512m -XX:+UseSerialGC -XX:MaxMetaspaceSize=128m \
        -jar bfg.jar \
        --delete-folders build \
        cloud-atlas.git

- 执行以下命令真正释放空间::

   cd cloud-atlas.git
   git reflog expire --expire=now --all && git gc --prune=now --aggressive

此时运行 ``du -sh .`` 可以看到文件目录体积明显缩小(从 815M 缩减到 265M)

- 最后将清理后的历史推送到远程仓库::

   # 强制推送所有分支和标签
   git push --force origin "refs/heads/*"
   git push --force origin "refs/tags/*"

折腾记录
==========

以下是我的一些尝试和报错经历，总结为上文::

   git push --force

这里我遇到报错::

   Enumerating objects: 46089, done.
   Writing objects: 100% (46089/46089), 262.21 MiB | 5.51 MiB/s, done.
   Total 46089 (delta 0), reused 0 (delta 0), pack-reused 46089 (from 1)
   remote: Resolving deltas: 100% (25060/25060), done.
   ...
   remote: 
   To github.com:huataihuang/cloud-atlas.git
    + 28405bae...ee1d8889 dependabot/pip/source/urllib3-2.6.0 -> dependabot/pip/source/urllib3-2.6.0 (forced update)
    + 87938182...e1339f71 dependabot/pip/urllib3-2.6.0 -> dependabot/pip/urllib3-2.6.0 (forced update)
   ...

Google Gemini解释说是因为本地仓库包含了从GitHub同步过来的 ``Pull Request (PR) 引用（形如 refs/pull/...）`` : 在执行 ``git clone --mirror`` 时，Git 会把仓库里所有的引用（包括 PR 的缓存）都克隆下来。但 GitHub 禁止用户推送或修改 ``refs/pull/`` 路径下的引用，因为这些是系统自动生成的只读记录。

解决方法是: 明确告诉 Git **只推送分支和标签** ，避开那些隐藏的 ``PR`` 引用。

按照Gemini建议将修改命令为::

   # 只推送所有的本地分支 (refs/heads/*) 和标签 (refs/tags/*)
   git push --force origin 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'

此时报错::

   fatal: --mirror can't be combined with refspecs

这个报错是因为最初克隆仓库时使用了 ``--mirror`` 参数，在Git配置中， ``mirror`` 模式会将整个远程同步逻辑所定位 **一对一完全映射** ，所以不允许在 ``push`` 命令中指定 ``refspecs`` (即指定分支规则)。

解决方法是 **临时关闭镜像模式** 或者用更为简单的方法来绕过它:

- 修改Git配置: 暂时不要以 **镜像** 方式运行，所以在镜像仓库目录( ``.git`` 结尾的目录)中运行以下命令::

   # 关闭镜像推送行为
   git config remote.origin.mirror false

然后再次执行::

   # 跳过github不允许修订的部分
   git push --force origin 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'

发现只是提示::

   Everything up-to-date

远程没有任何变化

WHY?

我突然想到是我修订了 ``.gitignore`` ，设置了 ``build/`` ，这应该导致无法提交 ``build/`` 目录内容。所以我暂时注释掉 ``.gitigore`` 中这行内容，重新提交::

   git push --force origin 'refs/heads/*:refs/heads/*' 'refs/tags/*:refs/tags/*'

这样就能够正常提交

但是，我发现远程仓库的 build 目录还存在，并没有消失

WHY?

Gemini提示，是因为BFG默认不修改你最后一次提交的内容。由于当前代码中正包含着 ``build/`` 目录，所以BFG运行完后会提示： ``Protected objects: 1 (these objects were not changed because they are referenced by your HEAD)``

解决方法： 在运行 BFG 之前，先在正常工作目录里手动删除并提交一次::

   git rm -r --cached build/
   git commit -m "Remove build directory before cleaning history"
   git push

然后重新运行BFG清理历史

另外一个原因是只推送了单一分支： 如果关闭了镜像模式后，只运行了简单的 ``git push`` ，可能只更新了 ``main`` 分支。如果远程仓库的其他分支还带这份重担，GitHub 依然会显示仓库很大。

关于 ``--mirror`` 参数
-----------------------

普通的 ``git clone`` 只会下载远程的当前分支。如果你只清理当前分支，而其他分支（如 ``develop`` 或旧的 ``feature`` 分支）里还残留着 ``build/`` 目录，那么：

- 仓库的总空间并不会减小
- 当合并分支时， ``build/`` 目录可能会“死灰复燃”。

``--mirror`` 会强制下载所有分支和所有标签，确保 BFG 能一次性把所有角落里的 ``build/`` 都扫干净。

为了避免 ``--mirror`` 带来的 ``refs/pull`` 报错太麻烦，可以改用 ``--bare`` 克隆，它比普通克隆全，但比镜像克隆“干净”一点。
