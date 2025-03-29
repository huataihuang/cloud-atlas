.. _kubectl_get:

=====================
kubectl的get命令案例
=====================

- 获取所有运行pod名字::

   kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'

这个方法是采用 `go语言模版 <https://golang.org/pkg/text/template/>`_ 来实现的，可以通过 ``kubectl describe -o yaml pod <NAME>`` 来获得可以查看的字段，并通过上述方式查询。

此外，可以通过 template 文件来定制输出，举例创建一个 ``mypods.template`` 文件如下::

   Namespace       Name    CreateTime    PodIP  NodeIP   NetworkMode
   {.metadata.namespace}   {.metadata.name}   {.metadata.creationTimestamp}   {.metadata.labels['k8s\.mycluster/ip']}  {.status.hostIP}  {.metadata.annotations['io\.mycluster\.docker\.network']}

然后执行查询::

   kubectl get pods --all-namespaces -l custom.k8s.huatai.me/runtime-class=runc -o custom-columns-file=mypods.template > mypods.txt

可以获得一个定制输出的列表

参考
=====

- `kubernetes list all running pods name <https://stackoverflow.com/questions/35797906/kubernetes-list-all-running-pods-name>`_
