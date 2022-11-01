.. _git_startup:

===================
git快速起步
===================

.. note::

   本文以实用为主，介绍如何将远程仓库下载到本，创建开发分支，提交远程仓库以及合并等简单操作，目的是辅助完成开发。所以不深究细节和原理，仅完成日常80%操作为主。

配置提交用户
=============

在提交软件仓库前需要先配置提交人账号，配置分为全局 ``global`` 和针对某个特定仓库的 ``local`` 。一般常用提交人账号配置为 ``global`` ，而少量仓库则配置 ``local`` 

- 配置全局账号::

   git config --global user.email "your_email@example.com"
   git config --global user.name "your_email"

- 对于我的个人项目，我按照项目目录进行配置::

   cd cloud-atlas
   git config --local user.email "huataihuang@xxx.xx"
   git config --local user.name "huataihuang"

配置git终端色彩
==================

git提供了支持终端的色彩显示，用以下命令开启::

   git config --global color.ui auto

获取远程版本
===============

- 从远程主机clone出一个版本库::

   git clone git@github.com:huataihuang/cloud-atlas.git

- 如果远程服务器版本有了更新，将远程更新更新取回本地(例如origin主机的master分支)::

   git fetch origin master

- 检查所有分支(包括本地和远程)::

   git branch -a

分支
========

- 切换分支::

   git checkout XXX

- 如果想在当前分支上创建一个本地分支进行开发(通常我们会在 ``master`` 分支上创建本地开发分支)::

   git checkout -b new_fix_XXX

- 然后将本地分支推送到远程服务器，方便后续不断同步开发::

   # 修改，并 git commit，然后执行
   git push origin new_fix_XXX --force

注意：本地分支名字必须和远程分支名字相同，例如，这里分支名字是 ``new_fix_XXX``

回滚
=======

如果还没有提交到远程库的回滚
------------------------------

如果还没有提交到远程代码库，放弃修改的方法如下:

- 先查看有哪些 ``commit`` ::

   git log

例如::

   commit d5c92f618314fb2f8759cfc77e167de3986c3548
   ...
   commit 559770899a4e5bd8314a0ea196f433f3103dadbf
   ...

这里假设 ``d5c92f618314fb2f8759cfc77e167de3986c3548`` 是commit但是尚未push，准备回滚到上一个版本 ``559770899a4e5bd8314a0ea196f433f3103dadbf``

- 回滚::

   git reset --hard 559770899a4e5bd8314a0ea196f433f3103dadbf

- 然后再次检查::

   git log

放弃修改并更新远程分支
------------------------

- 本地代码回滚到上一版本（或者指定版本）::

   git reset --hard HEAD~1

- 加入 ``-f`` 参数，强制提交，远程端将强制跟新到reset版本::

   # git push -f origin master
   git push -f

合并分支
===========

- 将hotfix分支合并到当前分支中::

   git merge hoxfix

删除分支
=========

- 删除分支hotfix， ``-d`` 选项只能删除被当前分支所合并过的分支，要强制删除没有被合并过的分支，使用参数 ``-D`` ::

   git branch -d hotfix

查看分支间的不同
===================

- 比较当前分支和 ``branchName`` 分支之间的不同::

   git diff branchName

- 查看两个分支间的差异::

   git diff branch1 branch2

- 比较两个分支的文件::

   git diff <branchA>:<fileA> <branchB>:<fileB>

其他进阶
==========

- :ref:`git_merge_fix_conflicts`

参考
======

- `Git远程操作详解 <http://www.ruanyifeng.com/blog/2014/06/git_remote.html>`_
- `How to clone all remote branches in Git? <http://stackoverflow.com/questions/67699/how-to-clone-all-remote-branches-in-git>`_
- `Git查看、删除、重命名远程分支和tag <https://blog.zengrong.net/post/1746.html>`_
- `git branch <http://www.cnblogs.com/gbyukg/archive/2011/12/12/2285425.html>`_
- `How to colorize output of git? <https://unix.stackexchange.com/questions/44266/how-to-colorize-output-of-git>`_
