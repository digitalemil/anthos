#!/bin/bash

curl --request POST \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --data '' \
  https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize

  
gcloud container clusters get-credentials ${CLUSTER_NAME}

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole=cluster-admin \
  --user="$(gcloud config get-value core/account)"

cd istio-1.4.6-asm.0

export PATH=$PWD/bin:$PATH

#  --set "kiali.enabled=true" \
#  --set "kiali.dashboard.jaegerURL=http://jaeger-query:16686" \
#  --set "kiali.dashboard.grafanaURL=http://grafana:3000" \
#  --set "grafana.enabled=true" \

./bin/istioctl manifest apply --set profile=asm \
  --set values.global.trustDomain=${IDNS} \
  --set values.global.sds.token.aud=${IDNS} \
  --set values.nodeagent.env.GKE_CLUSTER_URL=https://container.googleapis.com/v1/projects/${PROJECT_ID}/locations/${CLUSTER_ZONE}/clusters/${CLUSTER_NAME} \
  --set values.global.meshID=${MESH_ID} \
  --set values.global.proxy.env.GCP_METADATA="${PROJECT_ID}|${PROJECT_NUMBER}|${CLUSTER_NAME}|${CLUSTER_ZONE}"

kubectl wait --for=condition=available --timeout=600s deployment --all -n istio-system  

sleep 60

gcloud auth application-default login

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${CLUSTER_ZONE} --project ${PROJECT_ID}

asmctl validate

#echo https://pantheon.corp.google.com/marketplace/details/google/anthos.googleapis.com?_ga=2.232042655.1290840127.1583832185-1207503329.1575889142

#kubectl patch svc grafana --namespace istio-system -p '{"spec": {"type": "LoadBalancer"}}'
#kubectl patch svc kiali --namespace istio-system -p '{"spec": {"type": "LoadBalancer"}}'

cd ..
#kubectl apply -f metrics.yaml
