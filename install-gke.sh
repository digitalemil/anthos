#!/bin/bash

gcloud config set project ${PROJECT_ID}

gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    cloudtrace.googleapis.com \
    meshca.googleapis.com \
    meshtelemetry.googleapis.com \
    meshconfig.googleapis.com \
    iamcredentials.googleapis.com \
    stackdriver.googleapis.com \
    binaryauthorization.googleapis.com \
    anthos.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    cloudresourcemanager.googleapis.com \
    anthos.googleapis.com

gcloud config set compute/zone ${CLUSTER_ZONE}

# --addons=HttpLoadBalancing,CloudRun \
gcloud beta container clusters create ${CLUSTER_NAME} \
    --cluster-version=1.16.9-gke.6 \
    --machine-type=e2-standard-4 \
    --image-type "UBUNTU" \
    --num-nodes=3 \
    --identity-namespace=${IDNS} \
    --enable-stackdriver-kubernetes \
    --enable-cloud-run-alpha \
    --enable-binauthz \
    --subnetwork=default \
    --labels mesh_id=${MESH_ID}

gcloud container binauthz policy import allow.yaml
