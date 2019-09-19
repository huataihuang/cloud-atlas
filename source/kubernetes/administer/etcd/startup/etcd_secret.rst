.. _etcd_secret:

=================
etcd secret操作
=================

.. note::

   我这里操作可能不规范，仅是实践记录。目前还没有找到合适的参考文档。

   本文记录如何从已经部署好的etcd集群获取客户端的证书以及etcd的ca证书，以便能够通过 etcdctl 操作服务器。

- 获取etcd client证书::

   kubectl -n my-k8s-cluster get secret master-pki -o yaml | grep apiserver-etcd-client.key \
     | awk '{print $2}' | base64 -D > apiserver-etcd-client.key

   kubectl -n my-k8s-cluster get secret master-pki -o yaml | grep apiserver-etcd-client.crt \
     | awk '{print $2}' | base64 -D > apiserver-etcd-client.crt

- 访问etcd::

   etcdctl --cert=apiserver-etcd-client.crt --key=apiserver-etcd-client.key \
     --endpoints=https://etcd.test.huatai.me:2379 get abc

提示错误::

   {"level":"warn","ts":"2019-09-19T16:02:07.232+0800","caller":"clientv3/retry_interceptor.go:61","msg":"retrying of unary invoker failed","target":"endpoint://......:2379","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest connection error: connection error: desc = \"transport: authentication handshake failed: x509: certificate signed by unknown authority\""}

这个报错是因为没有提供自签名的etcd服务器的CA证书。

获取etcd的ca证书::

   kubectl -n my-k8s-cluster get secret master-pki -o yaml | grep etcd-ca.crt | awk '{print $2}' | base64 -D > etcd-ca.crt

命令行加上etcd服务器的ca证书 - ``--cacert=""`` ::

   etcdctl --cert=apiserver-etcd-client.crt --key=apiserver-etcd-client.key \
     --cacert=etcd-ca.crt \
     --endpoints=https://etcd.test.huatai.me:2379 get abc

这样就不在报错，正常操作。
