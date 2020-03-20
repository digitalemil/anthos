#!/bin/bash

gcloud container hub memberships register $MEMBERSHIP_NAME \
   --project=$PROJECT_ID \
   --gke-cluster=$GKE_CLUSTER \
   --service-account-key-file=$LOCAL_KEY_PATH


#gcloud container clusters update \
#$CLUSTER_NAME \
#--update-addons=CloudRun=ENABLED,HttpLoadBalancing=ENABLED \
#--zone=$CLUSTER_ZONE
