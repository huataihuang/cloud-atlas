for sn in `seq 3`; do
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer x-k3s-m-${sn}.json | cfssljson -bare x-k3s-m-${sn}
done
