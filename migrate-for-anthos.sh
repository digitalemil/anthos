#!/bin/bash
source ./env.sh

gcloud config set project $PROJECT_ID


#Create Migration Cluster
gcloud container clusters create migration-processing --scopes="cloud-platform"    --project=$PROJECT_ID --zone=$CLUSTER_ZONE --machine-type n1-standard-4    --image-type ubuntu --num-nodes 1 --enable-stackdriver-kubernetes    --subnetwork "projects/$PROJECT_ID/regions/$CLUSTER_REGION/subnetworks/default" 
gcloud container clusters get-credentials migration-processing  --zone $CLUSTER_ZONE --project $PROJECT_ID

migctl setup install

migctl doctor

# Clean-up
rm Dockerfile deployment_spec.yaml migration.yaml pmml-migration.yaml
migctl migration delete pmml-migration
migctl source delete  pmml-source

migctl source create ce pmml-source --project $PROJECT_ID  --zone $CLUSTER_ZONE

migctl migration create pmml-migration --source pmml-source  --vm-id pmml-vm --intent ImageAndData

migctl migration generate-artifacts pmml-migration

migctl migration status -w pmml-migration

#migctl migration get-artifacts pmml-migration

#migctl migration cleanup pmml-migration --overwrite 
