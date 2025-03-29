git clone git@github.com:jrwren/kind.git
cd kind/images/base/

# 需要使用 buildkit ，否则会提示 the --chmod option requires BuildKit. Refer to https://docs.docker.com/go/buildkit/ to learn how to build images with BuildKit enabled
docker build -t kindest/node:v1.25.3-zfs .
