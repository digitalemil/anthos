#!/bin/bash

source ./env.sh

./install-gke.sh

read -p "Press enter to continue"

./prep_asm.sh

read -p "Press enter to continue"

./prep_register_cluster.sh

read -p "Press enter to continue"

./register_cluster.sh

read -p "Installing knative. Press enter to continue"
kubectl apply --selector knative.dev/crd-install=true --filename https://github.com/knative/serving/releases/download/v0.11.0/serving.yaml
kubectl apply --filename https://github.com/knative/serving/releases/download/v0.11.0/serving.yaml 


read -p "Installing ConfigMgmt. Press enter to continue"
sed 's/%CLUSTER_NAME%/'"$CLUSTER_NAME"'/g' config-management.yaml.template >config-management.yaml
kubectl apply -f config-management-operator.yaml
kubectl apply -f config-management.yaml
