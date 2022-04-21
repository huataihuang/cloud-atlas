curl -sfL https://get.k3s.io | K3S_TOKEN="some_random_password" \
                               K3S_DATASTORE_ENDPOINT='https://etcd.edge.huatai.me:2379' \
                               K3S_DATASTORE_CAFILE='/etc/etcd/ca.pem' \
                               K3S_DATASTORE_CERTFILE='/etc/etcd/client.pem' \
                               K3S_DATASTORE_KEYFILE='/etc/etcd/client-key.pem' \
                               INSTALL_K3S_EXEC='--write-kubeconfig-mode=644' \
                               sh -s - server --cluster-init --tls-san `hostname`
