.. _intro_gitea:

===============
Gitea简介
===============

`Gitea - Git with a cup of tea <https://gitea.io/>`_ 是一个社区开源的Git服务，实现了类似 github / gitlab 的代码管理服务。这个开源项目采用了Go语言开发，致力于实现轻量级的代码托管解决方案。

作为轻量级的Linux - :ref:`alpine_linux` ，结合这样的轻量级代码托管服务，来实现个人的开发持续集成环境，是验证和探索 :ref:`info_service` 的一种尝试。并且，我想在我构建 :ref:`edge_cloud` 的 :ref:`k3s` 环境完整实现一个个人开发环境，选择 Gitea作为代码托管平台。

.. note::

   轻量级Git仓库也可以选择 `Gogs - A painless self-hosted Git service <https://gogs.io/>`_ ，是 Gitea 的来源项目，两者区别不大，主要差异是社区驱动方式差异:

   - Gogs是unknown(中文昵称:无闻 `无闻的博客unknwon.io <https://unknwon.io/>`_ )发起，且是主要代码贡献者和唯一维护人。无闻的博客是中英文双语，提供了一些开发和自我管理的见解，不过更新不多
   - Gitea是在Gogs基础上fork出的新开发分支，主要区别是由社区决定加入特性，所以新特性多一些

   `从 Gogs vs Gitea 看中外文化差异 #16 <https://github.com/wolfogre/blog-utterances/issues/16>`_ 提供了两者对比的一些观点，有意思

.. note::

   Gitea 以及 Gogs 没有提供完整的 CI/CD 功能，需要借助第三方持续集成。这点不如 GitLab 功能全面。不过，或许可以尝试结合 :ref:`jenkins` 来实现完整功能o

   `[疑问] Gitea 和 GItlab 各自的优势是什么?大家更偏向于哪种代码仓库？ <https://v2ex.com/t/808391>`_ 讨论了选择，简单来说:

   - 需要完整持续集成则使用 GitLab
   - 仅做代码展示，仅作为git仓库使用，并且使用成员较少，硬件性能有限，则可以使用 Gitea


参考
=====

- `alpine linux wiki: Gitea <https://wiki.alpinelinux.org/wiki/Gitea>`_
