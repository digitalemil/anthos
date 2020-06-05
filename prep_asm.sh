#!/bin/bash


export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
     --member user:$GCP_EMAIL_ADDRESS \
     --role=roles/editor \
     --role=roles/container.admin \
     --role=roles/resourcemanager.projectIamAdmin \
     --role=roles/iam.serviceAccountAdmin \
     --role=roles/iam.serviceAccountKeyAdmin \
     --role=roles/gkehub.admin

gcloud services enable \
    container.googleapis.com \
    compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    meshca.googleapis.com \
    meshtelemetry.googleapis.com \
    meshconfig.googleapis.com \
    iamcredentials.googleapis.com \
    anthos.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    cloudresourcemanager.googleapis.com

export WORKLOAD_POOL=${PROJECT_ID}.svc.id.goog
export MESH_ID="proj-${PROJECT_NUMBER}"
gcloud config set compute/zone ${CLUSTER_LOCATION}

gcloud container clusters describe ${CLUSTER_NAME}

gcloud container clusters update ${CLUSTER_NAME} \
  --update-labels=mesh_id=${MESH_ID}


gcloud container clusters update ${CLUSTER_NAME} \
   --workload-pool=${WORKLOAD_POOL}

gcloud container clusters update ${CLUSTER_NAME} \
   --enable-stackdriver-kubernetes

gcloud beta container clusters update ${CLUSTER_NAME} \
   --release-channel=regular




curl --request POST \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --data '' \
  https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize

  
gcloud container clusters get-credentials ${CLUSTER_NAME}

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)"

curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.5.4-asm.2-linux.tar.gz

tar xzf istio-1.5.4-asm.2-linux.tar.gz

cd istio-1.5.4-asm.2

export PATH=$PWD/bin:$PATH

istioctl manifest apply --set profile=asm \
  --set values.global.trustDomain=${WORKLOAD_POOL} \
  --set values.global.sds.token.aud=${WORKLOAD_POOL} \
  --set values.nodeagent.env.GKE_CLUSTER_URL=https://container.googleapis.com/v1/projects/${PROJECT_ID}/locations/${CLUSTER_LOCATION}/clusters/${CLUSTER_NAME} \
  --set values.global.meshID=${MESH_ID} \
  --set values.global.proxy.env.GCP_METADATA="${PROJECT_ID}|${PROJECT_NUMBER}|${CLUSTER_NAME}|${CLUSTER_LOCATION}"

kubectl wait --for=condition=available --timeout=600s deployment --all -n istio-system

asmctl validate

cd ..
