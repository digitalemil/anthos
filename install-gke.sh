#!/bin/bash

gcloud config set project ${PROJECT_ID}

gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    stackdriver.googleapis.com \
    meshca.googleapis.com \
    meshtelemetry.googleapis.com \
    meshconfig.googleapis.com \
    iamcredentials.googleapis.com \
    anthos.googleapis.com

gcloud config set compute/zone ${CLUSTER_ZONE}

# --addons=HttpLoadBalancing,CloudRun \
gcloud beta container clusters create ${CLUSTER_NAME} \
    --machine-type=n1-standard-4 \
    --num-nodes=4 \
    --identity-namespace=${IDNS} \
    --enable-stackdriver-kubernetes \
    --enable-cloud-run-alpha \
    --subnetwork=default \
    --labels mesh_id=${MESH_ID}

