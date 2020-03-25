#!/bin/bash

export PROJECT_ID=esiemes-default
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
export CLUSTER_NAME=anthos7
export CLUSTER_ZONE=us-central1-c
export IDNS=${PROJECT_ID}.svc.id.goog
export MESH_ID="proj-${PROJECT_NUMBER}"
export GCP_EMAIL_ADDRESS=esiemes@google.com
export SERVICE_ACCOUNT_NAME=anthos-$CLUSTER_NAME 
export LOCAL_KEY_PATH=localkey
export MEMBERSHIP_NAME=$CLUSTER_NAME
export GKE_CLUSTER=$CLUSTER_ZONE/$CLUSTER_NAME
