#!/bin/bash

HELM=helm
if [ ! -f $2/values-$1.yaml ]; then
    VALUES=""
else
    VALUES="-f $2/values-$1.yaml"
fi

DEPLOYS=$($HELM --namespace=$1 ls | grep $2 | wc -l)
echo "-- Install $2 $3"
if [ ${DEPLOYS} -eq 0 ]; then
    echo 'Deploy new'
    $HELM install $2 $2 --namespace=$1 --set service.name=$2 --set project.env=$1 --set project.name=$2 --set image.tag=$3 --wait --timeout 180s $VALUES;
else
    export STATUS=$($HELM --namespace=$1 status $2 | grep "STATUS" | head -n1 | cut -f2 -d' ');
    if [ "$STATUS" == "failed" ]; then
        echo 'Reinstall'
        $HELM del --namespace=$1 $2
        sleep 5
        $HELM install $2 $2 --namespace=$1 --set service.name=$2 --set project.env=$1 --set project.name=$2 --set image.tag=$3 --wait --timeout 180s $VALUES;
    else
        echo 'Upgrade'
        $HELM upgrade $2 $2 --namespace=$1 --set project.env=$1 --set image.tag=$3 --wait --timeout 180s $VALUES; 
    fi
fi
