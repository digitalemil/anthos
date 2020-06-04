
source env.sh

gcloud config set project $PROJECT_ID
gcloud auth login

gcloud beta container clusters update $CLUSTER_NAME --update-addons ConfigConnector=ENABLED
kubectl wait pod/configconnector-operator-0 -n configconnector-operator-system --for=condition=Initialized


gcloud iam service-accounts create cnrm-system-$CLUSTER_NAME --project $PROJECT_ID

export EMAIL=$(gcloud iam service-accounts list | grep cnrm-system-$CLUSTER_NAME | awk '{ print $1 }')
echo GSA: $EMAIL

sed 's/%EMAIL%/'"$EMAIL"'/g' config-connector.yaml.template >config-connector.yaml
sed 's/%EMAIL%/'"$EMAIL"'/g' configconnectorcontext.yaml.template >configconnectorcontext-1.yaml.template
sed 's/%PROJECT_ID%/'"$PROJECT_ID"'/g' configconnectorcontext-1.yaml.template >configconnectorcontext.yaml

gcloud projects add-iam-policy-binding $PROJECT_ID  --member "serviceAccount:$EMAIL"  --role "roles/owner"
#gcloud projects add-iam-policy-binding $PROJECT_ID  --member "serviceAccount:$EMAIL"  --role "roles/spanner.admin"

gcloud iam service-accounts keys create  --iam-account "$EMAIL"  ./key.json

kubectl create namespace cnrm-system

kubectl create secret generic gcp-key  --from-file ./key.json  --namespace cnrm-system

rm ./key.json

#gsutil cp gs://cnrm/latest/release-bundle.tar.gz release-bundle.tar.gz

#tar zxvf release-bundle.tar.gz

#kubectl apply -f install-bundle-gcp-identity/

kubectl create ns $PROJECT_ID


sleep 10



#kubectl apply -f config-connector.yaml

#sleep 10

#kubectl get crds --selector cnrm.cloud.google.com/managed-by-kcc=true


kubectl wait -n cnrm-system  --for=condition=Initialized pod  cnrm-controller-manager-0


#kubectl apply -f configconnectorcontext.yaml

#sleep 10


#kubectl get serviceaccount/cnrm-controller-manager-$PROJECT_ID -n cnrm-system

#kubectl wait -n cnrm-system  --for=condition=Initialized pod  cnrm-controller-manager-[NAMESPACE]-$PROJECT_ID

#gcloud projects add-iam-policy-binding $PROJECT_ID  --member "serviceAccount:$EMAIL"  --role "roles/iam.workloadIdentityUser"
#gcloud iam service-accounts add-iam-policy-binding \
#    --role=roles/iam.workloadIdentityUser \
#    --member="serviceAccount:esiemes-default.svc.id.goog[cnrm-system/cnrm-controller-manager-esiemes-default]" \
#    cnrm-system@esiemes-default.iam.gserviceaccount.com



#sleep 10
#kubectl annotate namespace $PROJECT_ID  cnrm.cloud.google.com/project-id=$PROJECT_ID


kubectl wait -n cnrm-system  --for=condition=Ready pod --all
