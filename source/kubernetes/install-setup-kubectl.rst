.. _install-setup-kubectl:

==================
安装和设置kubectl
==================

在安装并运行了minikube之后，我们需要在主机上安装kubectl，以便能够管理kubernetes集群（这里即为minikube单机）。

安装kubectl
===============

CentOS, RHEL, Fedora 安装kubectl
----------------------------------

- 通过官方软件仓库安装kubectl::

   cat <<EOF > /etc/yum.repos.d/kubernetes.repo
   [kubernetes]
   name=Kubernetes
   baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
   enabled=1
   gpgcheck=1
   repo_gpgcheck=1
   gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
   EOF
   yum install -y kubectl

.. note::

   通过Google官方软件库安装需要 :ref:`openconnect_vpn`

Ubuntu, Debian 安装kubectl
-----------------------------

- 通过官方软件仓库安装kubectl::

   sudo apt-get update && sudo apt-get install -y apt-transport-https
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
   echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
   sudo apt-get update
   sudo apt-get install -y kubectl

配置kubectl
==============

为了能够使kubectl发现并访问Kubernetes集群，需要使用 `kubeconfig <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>`_ 配置文件，这个配置文件是通过使用 ``kube-up.sh`` 脚本创建集群自动生成，或者是部署minikube集群生成的。

如果要访问多个kubernetes集群，请参考 `Shareing Cluster Access document <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/>`_ 。我将在后续撰写相关实践文档。

默认的kubectl配置文件位于 ``~/.kube/config`` ，由于我们之前已经成功部署了一个minikube集群，所以现在这个文件看上去如下:::

   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority: /home/huatai/.minikube/ca.crt
       server: https://192.168.39.85:8443
     name: minikube
   contexts:
   - context:
       cluster: minikube
       user: minikube
     name: minikube
   current-context: minikube
   kind: Config
   preferences: {}
   users:
   - name: minikube
     user:
       client-certificate: /home/huatai/.minikube/client.crt
       client-key: /home/huatai/.minikube/client.key

- 现在我们来验证集群状态::

   kubectl cluster-info

显示输出::

   Kubernetes master is running at https://192.168.39.85:8443
   KubeDNS is running at https://192.168.39.85:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

这表明之前安装的minikube已经正常工作了。

更详细的集群信息可以通过如下命令显示::

   kubectl cluster-info dump

激活shell自动补全
====================

kubectl包含了一个自动补全命令功能，可以大大提高工作效率。

.. note::

   CentOS可能需要先安装 ``bash-completion`` 软件包::

      yum install bash-completion -y

   Ubuntu则默认已经安装了 ``bash-completion``

为了能够在当前shell中使用kubectl的自动补全功能，请执行 ``source <(kubectl completion bash)``

也可以加入shell环境变量，这样登陆就可以使用::

   echo "source <(kubectl completion bash)" >> ~/.bashrc

参考
==========

- `Install and Set Up kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_

