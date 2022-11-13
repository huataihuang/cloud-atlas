#!/bin/bash

cpid=$1
while true; do
        ppid=$(ps -o ppid= -p $cpid)
        pname=$(ps -o comm= -p $ppid)
        if [ "$pname" == "docker" ]; then
                echo "$cpid parent $ppid ($pname)"
                break
        else
                echo "$cpid parent $ppid ($pname)"
                cpid=$ppid
        fi
done

docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.Name}}' | grep $cpid
