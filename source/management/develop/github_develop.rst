.. _github_develop:

====================
GitHub上的开发工作
====================

组织账号(organization account)
================================

也许对于个人开发者，也会想要创建一个类似组织的公共账号，例如创建个人品牌或者网站，对外提供服务等等。在GitHub有3种账号:

- 个人账号(personal account)
- 组织账号(organization account)
- 企业账号(enterprise account)

其中组织账号也可以由个人创建，形成一个虚拟的协作组织。

.. warning::

   个人账号可以转为组织账号，但是有很多限制(虽然提供了更精细的权限):

   - 将无法登陆转换后的个人账户
   - 转换后不能创建和修改gists
   - 组织账号不能再转回个人账号
   - SSH 密钥、OAuth 令牌、工作配置文件、reactions和关联的用户信息不会转移到组织
   - 安装在转换后的个人帐户上的所有 GitHub Apps 都将被卸载
   - 使用转换后的个人帐户进行的任何提交都将不再链接到该帐户
   - 提交本身将保持不变
   - 转换后的个人帐户所做的任何现有评论将不再链接到该帐户；评论本身将保持不变，但将与幽灵用户相关联
   - 使用转换后的个人帐户创建的私人存储库的任何分支都将被删除

.. note::

   **看起来个人账户转组织账户风险极高** 所以我采用 ``Keep your personal account and create a new organization manually`` (保持个人账号并手工创建组织)

保持个人账号并手工创建组织
=============================

.. note::

   我的需求是创建一个 ``cloud-atlas`` 组织，来构建我云计算的企业级模拟

最初我没有了解清楚，只想着能够在GitHub上申请到一个名为 ``cloud-atlas`` 的账号来体现我模拟云计算。不过，实际上 ``Cloud Atlas`` 这个名字太常用了，已经无法注册这两个单词的不同组合。我退而求其次，注册了和我的域名 ``cloud-atlas.io`` 相近的账号名 ``cloud-atlas-io`` 。

不过 ``cloud-atlas-io`` 申请的是个人账号，当我仔细阅读帮助文档，发现其实应该在我原先长期使用的个人账号 ``huataihuang`` 中创建组织，也就是采用如下步骤:

- 刚申请的个人账号 ``cloud-atlas-io`` 已经占用了这个名字，所以需要先修改这个个人账号的名字
- 在个人账号 ``huataihuang`` 中创建一个 ``新组织``
- (可选)将个人仓库转换到组织账号下

修改个人账户名
----------------

.. warning::

   GitHub的账号操作有很多限制和要求，请仔细参考官方帮助

.. note::

   - 修改用户名，GitHub 会自动将引用重定向到你的存储库(也就是老的名字还能一段时间可用，类似http重定向)
   - 但是需要注意，如果你的旧用户名后来被其他人使用了，则这个重定向功能会覆盖失效，所以建议更改用户名后更新现有的远程软件仓库URL(废弃掉旧名字，改为新用户名的URL)

- 在GitHub的任何页面都可以访问，点击 ``profile`` 照片，然后点击 ``Settings``

- 点击 ``Account`` ，在这个页面上有一个 ``Change username`` 部分，点击 ``Change username`` 按钮

  - 阅读说明后，输入新的用户名(如果不重名)

- 等待几分钟后，再次访问首页，就会看到自己的个人账号名已经修订成功

从个人账号创建组织
---------------------

现在我期望的名字 ``cloud-atlas-io`` 已经空闲，所以我就可以从我一直使用的个人账号 ``huataihuang`` 中创建

- 在GitHub的任何页面都可以访问，点击 ``profile`` 照片，然后点击 ``Settings``
- 在左边的导航栏中点击 ``Organizations``
- 在 ``Organizations`` 部分，点击 ``New organization``
- 按照指引，创建一个新组织 ``cloud-atlas-io`` (也就是我刚才让出的个人账号名)，这里会有一些选项，填写关联电子邮件账号(可以是原先的 ``huataihuang`` 用户注册邮件地址)

一切就绪，现在访问 http://github.com/cloud-atlas-io 就能够访问我为后续云计算模拟创建的组织了。我将在这个基础上构建一个虚拟组织，来部署一个互联网云计算。

参考
=====

- `Converting a user into an organization <https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-your-personal-account/converting-a-user-into-an-organization>`_
- `Changing your GitHub username <https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-personal-account-settings/changing-your-github-username>`_
- `Creating a new organization from scratch <https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch>`_
