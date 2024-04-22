.. _git_commit_or_stash:

=======================
Git提交变更或放弃变更
=======================

当我在不同的主机上修改我的git仓库文件时，有时候会因为忘记及时提交修改，而在另外一台主机上基于以前的提交做了变更修改并提交了仓库。此时 ``git pull`` 会出现合并冲突提示:

.. literalinclude:: git_commit_or_stash/git_error
   :caption: 修改冲突导致无法git pull

这种情况下，需要决定:

- 本地修改的文件是否要继续提交
- 本地修改的文件是否要放弃提交(回滚)

参考
=======

- `Git commit your changes or stash them before you can merge Solution <https://careerkarma.com/blog/git-commit-your-changes-or-stash-them-before-you-can-merge/>`_
