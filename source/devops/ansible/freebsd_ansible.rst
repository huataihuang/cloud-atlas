.. _ansible_freebsd:

==============================
在FreeBSD使用Ansible
==============================

在FreeBSD上安裝Ansible和 :ref:`python` 版本相关，例如操作系统默认python版本是 ``python3.11`` ，那么就安装 ``py311-ansible`` :

.. literalinclude:: freebsd_ansible/install
   :caption: 安装Ansible

我使用 :ref:`helix` ，所以对应配置 :ref:`freebsd_helix_lsp` 的 ``ansible-language-server`` :

.. literalinclude:: ../../freebsd/desktop/helix/freebsd_helix_lsp/ansible_lsp
   :caption: 安装ansible-language-server 

并配置 :ref:`freebsd_helix_lsp` 的 ``~/.config/helix/languages.toml`` :

.. literalinclude:: ../../freebsd/desktop/helix/freebsd_helix_lsp/languages.toml
   :caption: ansible LSP支持
   :emphasize-lines: 41-54

参考
======

- `FreeBSD Ansible: Install <https://www.server-world.info/en/note?os=FreeBSD_14&p=ansible&f=1>`_
- `How to prepare FreeBSD server to be managed by Ansible tool <https://www.cyberciti.biz/faq/how-to-prepare-freebsd-server-to-be-managed-by-ansible-tool/>`_
