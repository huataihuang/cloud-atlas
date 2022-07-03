for sn in `seq 3`; do
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer z-b-data-${sn}.json | cfssljson -bare z-b-data-${sn}
done
