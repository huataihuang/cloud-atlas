.. _openssl_gencert_files:

===========================
OpenSSL生成的证书文件格式
===========================

我在 :ref:`etcd_tls` 使用Cloudflare 的 ``cfssl`` 工具来生成 :ref:`etcd` 集群证书，分别有3中用途证书，每种证书包含3个文件(2种后缀名的文件)：

- ``.pem``
- ``.csr``

那么这些不同文件的不同后缀名分别代表什么含义，以及什么用途呢？跟着手册做一遍，依然一头雾水，所以我在这里整理OpenSSL生成证书文件格式，以便能够区分和理解这些密钥证书的用途。

SSL标准文件
===============

SSL标准有非常长的历史，并且有各种格式，最终这些格式标准被汇总编成 `Abstract Syntax Notation 1 (ASN.1) <https://en.wikipedia.org/wiki/ASN.1>`_ (抽象语法符号标准1)格式化数据，也就是x509证书所使用的格式:

- ``.csr`` : ``Certificate Signing Request`` (证书签名请求)，一些应用程序生成 ``.csr`` 证书签名请求提交给证书颁发机构(certificate-authorities)。 ``.csr`` 文件的实际格式是 RFC 2986 中定义的PKCS10，包含了所请求证书的 部分/全部 关键细节，例如 主题(subject),组织(organization),状态(state),诸如此类，以及要签署的证书的公钥。返回的证书则是公共证书(public certificate)，也就是包含公钥但不包含私钥，并且返回的公共证书有多种格式。

- ``.pem`` : 在 RFC 1422(是RFC1421到1424的一部分)定义，这是一种容器格式(container format)，可能只包含公共证书(public certificate)。例如Apache安装时，CA证书文件 ``/etc/ssl/certs`` ；也可能包含整个证书链(entire certificate chain)，即包含公钥(public key)、私钥(private key)以及根证书(root certificates)。但是很不幸，令人迷惑的是， ``.pem`` 文件还可能编码了 CSR，因为PKCS10格式可以转换为PEM。 **这个名字来自隐私增强邮件(Privacy Enhanced Mail, PEM)** ，虽然这是一个失败的安全电子邮件方法，但是使用的容器格式依然存在，并且是 x509 ASN.1 密钥的 ``base64`` 转换

- ``.key`` : ``.key`` 文件是只包含 ``私钥`` PEM格式文件，这是一种常规名称而不是标准化名称。在Apache安装中，这个文件通常位于 ``/etc/ssl/private`` 目录。这个私钥 ``.pem`` 文件权限非常重要，如果设置错误，一些程序会拒绝加载这些证书。

- ``.pkcs12`` / ``.pfx`` / ``.p12`` : 最初由 RSA 在公钥加密标准（缩写为 PKCS）中定义，“12”变体最初由 Microsoft 增强，后来作为 RFC 7292 提交。这是一种受密码保护的容器格式，包含公共和私有证书对。与 ``.pem`` 文件不同，容器是完全加密的。 Openssl 可以将其转换为带有公钥和私钥的 ``.pem`` 文件： ``openssl pkcs12 -in file-to-convert.p12 -out convert-file.pem -nodes``

- ``.der`` : 一种以二进制编码 ASN.1 语法的方法。 ``.pem`` 文件只是一个 Base64 编码的 ``.der`` 文件。 OpenSSL 可以将这些转换为 ``.pem`` ( ``openssl x509 -inform der -in to-convert.der -out converted.pem`` )。 Windows 将这些视为证书文件。 默认情况下，Windows 会将证书导出为具有不同扩展名的 .DER 格式文件。

- ``.cert`` / ``.cer`` / ``.crt`` :  这些文件类型是使用不同扩展名的 ``.pem`` 格式文件，Windows Explorer 将其识别为证书，但不会把 ``.pem`` 视为证书


参考
======

- `What is a Pem file and how does it differ from other OpenSSL Generated Key File Formats? <https://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file>`_
