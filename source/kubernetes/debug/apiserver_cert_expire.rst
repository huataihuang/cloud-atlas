.. _apiserver_cert_expire:

=================
Apiserver证书过期
=================

在处理了 :ref:`kubelet_cert_expire` 之后，需要未雨绸缪，考虑 apiserver 的证书过期问题。

默认签发的apiserver证书，有效期是 ``10年`` ，所以需要注意如果到期之前，需要及时更新，否则会酿成故障。

参考
======

- `how to renew the certificate when apiserver cert expired? #581 <https://github.com/kubernetes/kubeadm/issues/581>`_
