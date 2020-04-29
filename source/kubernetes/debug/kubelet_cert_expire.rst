.. _kubelet_cert_expire:

=================
Kubelet证书过期
=================

kubelet节点日志显示客户端证书过期::

   E0427 15:38:51.829964   63737 bootstrap.go:205] Part of the existing bootstrap client certificate is expired: 2020-02-23 15:48:00 +0000 UTC
   I0427 15:38:51.830135   63737 bootstrap.go:61] Using bootstrap kubeconfig to generate TLS client cert, key and kubeconfig file
   I0427 15:38:51.830667   63737 certificate_store.go:131] Loading cert/key pair from "/etc/kubernetes/pki/kubelet-client-current.pem".
   I0427 15:38:51.842565   63737 bootstrap.go:235] Failed to connect to apiserver: the server has asked for the client to provide credentials
   I0427 15:38:54.222238   63737 bootstrap.go:235] Failed to connect to apiserver: the server has asked for the client to provide credentials
   ...

kubelet v1.11.0开始，支持 ``rotateCertificates: true`` ，默认开启支持了自动客户端证书更新。

使用命令 ``ps aux | grep kubelet`` 可以看到开启参数::

   --feature-gates=RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true

如果你使用的是CentOS，可以编辑 ``/etc/sysconfig/kubelet`` 配置::

   KUBELET_EXTRA_ARGS=--fail-swap-on=false --feature-gates=RotateKubeletClientCertificate=true,RotateKubeletServerCertificate=true

但是，在我这个案例中，由于服务器端异常不断重启，导致客户端证书更新没有生效。而apiserver稳定之后，客户端证书已经过期。所以需要修复这个客户端证书过期异常。

解决方法是重新生成客户端证书

- kubelet好像有一个 ``bootstrap-kubelet.conf`` 配置了证书失效的时间，停止kubelet，然后等待超时时间过期(10分钟)，然后再次启动kubelet。

- 另外也可以移除旧证书::

   rm /var/lib/kubelet/pki/kubelet-server-current.pem

然后重启kubelet::

   systemctl restart kubelet

不过，上述操作有可能并没有解决 kubelet-client-current.pem 问题，我查询到 `How to renew certificates on kubernetes 1.14.x <https://docs.wire.com/how-to/administrate/kubernetes/certificate-renewal/scenario-1_k8s-v1.14-kubespray.html>`_ 这个文档应该可以解决这个问题，但是操作比较复杂，需要线下演练。

.. note::

   另外，如果apiserver服务器的证书过期，有一个解决方案 `how to renew the certificate when apiserver cert expired? #581 <https://github.com/kubernetes/kubeadm/issues/581>`_ 我准备在适当时候验证一下

参考
======

- `Kubelet fails to authenticate to apiserver due to expired certificate #65991 <https://github.com/kubernetes/kubernetes/issues/65991>`_
