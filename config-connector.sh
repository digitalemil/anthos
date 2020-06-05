
source env.sh

gcloud config set project $PROJECT_ID
#gcloud auth login


gcloud iam service-accounts create cnrm-system-$CLUSTER_NAME --project $PROJECT_ID

export EMAIL=$(gcloud iam service-accounts list | grep cnrm-system-$CLUSTER_NAME | awk '{ print $1 }')
echo GSA: $EMAIL

gcloud projects add-iam-policy-binding $PROJECT_ID  --member "serviceAccount:$EMAIL"  --role "roles/owner"

gcloud iam service-accounts keys create  --iam-account "$EMAIL"  ./key.json

kubectl create namespace cnrm-system

kubectl create secret generic gcp-key  --from-file ./key.json  --namespace cnrm-system

rm ./key.json


kubectl create ns $PROJECT_ID

sleep 10


kubectl wait -n cnrm-system  --for=condition=Ready pod --all
