source env.sh

gcloud config set project $PROJECT_ID

gcloud iam service-accounts create cnrm-system --project $PROJECT_ID

export EMAIL=$(gcloud iam service-accounts list | grep cnrm-system | awk '{ print $1 }')

gcloud projects add-iam-policy-binding $PROJECT_ID \
 --member "serviceAccount:$EMAIL" \
 --role "roles/owner"

gcloud iam service-accounts keys create \
 --iam-account "$EMAIL" \
 ./key.json

kubectl create namespace cnrm-system

kubectl create secret generic gcp-key \
 --from-file ./key.json \
 --namespace cnrm-system

rm ./key.json

gsutil cp gs://cnrm/latest/release-bundle.tar.gz release-bundle.tar.gz

tar zxvf release-bundle.tar.gz

kubectl apply -f install-bundle-gcp-identity/

kubectl create ns esiemes-default

kubectl wait -n cnrm-system \
--for=condition=Initialized pod \
cnrm-controller-manager-0


