.. _intro_vault:

=================
vault简介
=================

`vault (GitHub) <https://github.com/hashicorp/vault>`_ 是著名的 HashiCorp 公司开发的安全凭证(secrets)管理工具。Vault能够为secrets提供统一的接口，同时提供严格的访问控制并记录详细的审计日志。

现代系统需要访问大量的secrets: 例如数据库凭证，外部服务的API密钥，面向服务的架构通信的凭证。如果没有secrets管理解决方案，密钥的生命管理、安全存储和详细的审计是不可能的，这就是valut提供的功能。

Vault提供的关键功能:

- 安全的secret存储: 任意key/value secrets可以存储在Vault中。secrets写入持久化存储前进行加密，以确保对原始存储访问权限不能访问secrets。
- 动态secrets: Vault 可以为某些系统（例如 AWS 或 SQL 数据库）按需生成secrets(按需生成有效期限的密钥对，租约到期后自动撤销)
- 数据加密: 可以自定义加密参数，加密数据可以存储在SQL数据库，无需用户设计自己的加密方法
- 租赁和续订：Vault 中的所有secrets都有与其关联的租约。 租约结束时，Vault 将自动撤销该秘密
- 撤销：Vault 内置了对secrets撤销的支持

待学习实践...

参考
======

- `vault (GitHub) <https://github.com/hashicorp/vault>`_
