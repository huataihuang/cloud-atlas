ETCD_VER=v3.5.2
KERNEAL=`uname -s` # Linux / Darwin
ARCH=`uname -m` # x86_64 / aarch64

if [ ${KERNEL} == "Linux" ];then
    KERNEL="linux"
else [ ${KERNEL} == "Darwin" ];then
    KERNEL="darwin"
else
    echo "Not Linux or macOS, exit!"
    exit 0
fi

if [ ${ARCH} == "x86_64" ];then
    ARCH="amd64"
elif [ ${ARCH} == "aarch64"  ];then
    ARCH="arm64"
else
    echo "Not x86_64 or aarch64, exit!"
    exit 0
fi

# choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-${KERNEL}-${ARCH}.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-${KERNEL}-${ARCH}.tar.gz -o /tmp/etcd-${ETCD_VER}-${KERNEL}-${ARCH}.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-${KERNEL}-${ARCH}.tar.gz -C /tmp/etcd-download-test --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-${KERNEL}-${ARCH}.tar.gz

/tmp/etcd-download-test/etcd --version
/tmp/etcd-download-test/etcdctl version
/tmp/etcd-download-test/etcdutl version

sudo mv /tmp/etcd-download-test/etcd /usr/local/bin
sudo mv /tmp/etcd-download-test/etcdctl /usr/local/bin
sudo mv /tmp/etcd-download-test/etcdutl /usr/local/bin
