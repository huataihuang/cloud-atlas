.. _think_write_doc:

=================
文档撰写的思考
=================

源起
========

我在十几年前，在一家小公司做运维的时候，就曾经尝试过不同的CMS，想要作为个人以及部门的知识管理平台。那个时期，iPhone 1st尚未发布，软件行业还没有现在这么流行的各种静态网站工具，很多CMS(内容管理系统)是基于PHP开发（Wordpress, Joomla, Drupal)或者基于Python的 `Plone <https://plone.org>`_
。那时候，我就一直在尝试不同的CMS/Wiki系统，而且每当看到精美的CMS网站(或者文档)，就想要了解是基于哪个平台实现的，自己是不是能构建出同样简洁美观的知识库。

如何借鉴CMS网站
-------------------

既然说到CMS借鉴，如何分辨和找到某个心仪网站的CMS本源？

如果网站确实使用了某个CMS系统，那么 `What CMS <https://whatcms.org/>`_ 提供了非常简单的检查方法: 输入网址就能够侦测该网站使用了哪个CMS平台。不过，如果网站是静态生成，例如 :ref:`sphinx_doc` ，那么这个标准的CMS检测工具就无能为力。

.. note::

   参考 `How to Tell What Website Builder Was Used  <https://dorik.com/blog/how-to-tell-what-website-builder-was-used>`_

倾向
=======

我比较中意的网站风格是:

- `OpenStack Documentation Installation Guide <https://docs.openstack.org/install-guide/overview.html>`_ 

我最初以为是OpenStack自己开发的文档系统，但是在页面上没有找到文档平台线索。偶尔也能在其他平台看到类似风格，所以基本肯定是一个通用平台。

后来，我找到一个规律，很多开源软件在GitHub的项目中往往会提供doc目录存储文档，其中就会提供文档如何撰写或者使用什么平台撰写。在openstack项目中也能找到: `OpenStack doc requirements <https://github.com/openstack/requirements/blob/master/doc/requirements.txt>`_ 可以看到文档是使用 :ref:`sphinx_doc` 

.. note::

   我尝试了 :ref:`sphinx_openstackdocstheme` ，发现还是需要做定制以移除默认嵌入的OpenStack网站的引用，所以并不是开箱即用。目前我暂时放弃，后续再看是否值得花费精力去定制修改。

.. note::

   好的文档规范能够增强协作， OpenStack 组织撰写了详细的 `OpenStack Documentation Contributor Guide <https://docs.openstack.org/doc-contrib-guide/>`_ ，提供详细的文档撰写实践指南。非常值得在构建大型项目时参考。

   同样 `OpenShift Documentation guidelines <https://github.com/openshift/openshift-docs/blob/main/contributing_to_docs/doc_guidelines.adoc>`_ 提供了良好建议。不过，需要注意的是，虽然OpenShift文档风格非常类似OpenStack，但是OpenShift文档是采用 `asiidoc <https://asciidoc.org/>`_ 完成的。所谓 ``asiidoc`` 采用了独特的MARK_UP方式撰写，语法结构不同于 MarkDown
   但是采用了一种变体文档格式，可能有比较大的学习成本。我并没有实践。

.. note::

   Red Hat官方文档风格也非常类似，但是不是采用 :ref:`sphinx_doc` ，而是类似WordPress的较为小众的 `Drupal <https://www.drupal.org/>`_

我的实践
=========

正如我在撰写 :ref:`cloud_atlas` ，文档是我梳理知识和想法最好的方式。我采用以下方式撰写文档:

- Sphinx Doc
- MkDocs
- GitBook
- Hugo

GitBook是我最早撰写 :ref:`cloud_atlas` 的 `Cloud Atlas 草稿 <https://github.com/huataihuang/cloud-atlas-draft>`_ 时使用的文档撰写平台。但我感觉GitBook采用Node.js来生成html，效率比较低，对于大量文档生成非常 缓慢。所以我仅更新源文件，很少再build生成最终的html文件。

Sphinx Doc是我撰写 :ref:`cloud_atlas` 的文档平台，我是模仿Kernel Doc的结构来撰写文档的，现在已经使用比较得心应手，感觉作为撰写书籍，使用Sphinx Doc是比较好的选择。

不过，Sphinx采用的reStructureText格式比较复杂(功能强大)，日常做快速笔记不如MarkDown格式。我发现MkDocs比较符合我的需求：

- 美观
- MarkDown语法
- 文档生成快速

此外，在很多Go语言开发项目中采用了 Hugo 作为文档系统，同样采用MarkDown格式的静态网站，定制性更强(也更复杂)，提供了大量的theme实现，甚至可以生成类似WordPress的个人网站。

我目前结合Sphinx 和 MkDoc 来完成日常工作学习的笔记

- Sphinx用于撰写集结成册的技术手册
- MkDoc用于日常工作笔记，记录各种资料信息采集

.. note::

   Sphinx Doc 和 MkDocs 都采用Python编写，可以共用Python virtualenv环境，这也是我比较喜欢这两个文档撰写工具的原因。

我的构想
==========

根据 `Jamstack: Site Generators <https://jamstack.org/generators/>`_ 统计，按照GitHub的Star数量排序， :ref:`nextjs` 是最受欢迎的静态网站生成器，其次是 :ref:`hugo`

我准备采用 :strike:`Hugo 来制作个人Blog` :ref:`nextjs` 来构建个人网站

.. note::

   `Jamstack <https://jamstack.org/>`_ 是网页托管领域独角兽 `Netlify <https://www.netlify.com/>`_ 的旗下产品。由于专注于CMS和Site，其网站提供了相关信息参考。

   - 参考 `Vercel 和 Netlify ，两大20亿美金估值的独角兽，在网页托管领域的崛起史 <https://zhuanlan.zhihu.com/p/525979886>`_
