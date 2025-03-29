#!/bin/bash

cpid=$1
while true; do
        ppid=$(ps -o ppid= -p $cpid)
        pname=$(ps -o comm= -p $ppid)
        if [ "$pname" == "containerd-shim" ]; then
                echo "$cpid parent $ppid ($pname)"
                break
        else
                echo "$cpid parent $ppid ($pname)"
                cpid=$ppid
        fi
done

crictl ps -q | xargs crictl inspect --output go-template --template '{{.info.pid}}, {{.status.metadata.name}}' | grep $cpid
