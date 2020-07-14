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
curl -LO https://storage.googleapis.com/gke-release/asm/istio-1.6.5-asm.1-linux-amd64.tar.gz
tar xzf istio-1.6.5-asm.1-linux-amd64.tar.gz
cd istio-1.6.5-asm.1
rm -fr asm
export PATH=$PWD/bin:$PATH
#gcloud components install kpt
sudo apt-get install google-cloud-sdk-kpt -y
kpt pkg get https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git/asm@release-1.6-asm .
#kpt pkg get https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git/asm@release-1.5-asm .
kpt cfg set asm gcloud.container.cluster ${CLUSTER_NAME}
kpt cfg set asm gcloud.compute.location ${CLUSTER_ZONE}
kubectl create namespace istio-system

#istioctl install --set profile=asm-multicloud
istioctl install -f asm/cluster/istio-operator.yaml

kubectl wait --for=condition=available --timeout=600s deployment --all -n istio-system

asmctl validate

cd ..
