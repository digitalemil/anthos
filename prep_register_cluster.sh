#!/bin/bash

gcloud projects add-iam-policy-binding $PROJECT_ID \
 --member user:$GCP_EMAIL_ADDRESS \
 --role=roles/gkehub.admin \
 --role=roles/iam.serviceAccountAdmin \
 --role=roles/iam.serviceAccountKeyAdmin \
 --role=roles/resourcemanager.projectIamAdmin

gcloud services enable \
 --project=$PROJECT_ID \
 container.googleapis.com \
 gkeconnect.googleapis.com \
 gkehub.googleapis.com \
 cloudresourcemanager.googleapis.com 

gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --project=$PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
 --member="serviceAccount:$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
 --role="roles/gkehub.connect"

 gcloud iam service-accounts keys create $LOCAL_KEY_PATH \
  --iam-account=$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
  --project=$PROJECT_ID
