#!/bin/bash
git clone https://github.com/GoogleCloudPlatform/click-to-deploy.git


python3 /google/migrate/anthos/gce-to-gke/clone_vm_disks.py \
-p esiemes-default \
-z us-central1-c \
-T us-central1-c \
-i pmml-vm \
-A pmml-vm \
-o pmml-vm.yaml

#sleep 20

#kubectl apply -f pmml-vm.yaml
