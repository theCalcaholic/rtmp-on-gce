#!/usr/bin/env bash

set -eu

echo "Parsing deployment templates..."
./.venv/bin/python parse.py

gcloud compute addresses describe rtmp-hls-server-ip --region=europe-west1 &> /dev/null || {
  gcloud compute addresses create rtmp-hls-server-ip --region=europe-west1 --network-tier=STANDARD
  echo "Creating external ip..."
}

gcloud compute disks describe rtmp-hls-data-disk --zone=europe-west1-b &> /dev/null || {
  echo "Creating data disk..."
  gcloud compute disks create rtmp-hls-data-disk \
    --zone=europe-west1-b \
    --size=20GB \
    --type=pd-ssd
}


echo "Creating compute instance..."
gcloud compute instances create rtmp-hls-server \
    --boot-disk-size=10 \
    --boot-disk-type=pd-standard \
    --disk=auto-delete=no,device-name=data,name=rtmp-hls-data-disk \
    --machine-type=n2-standard-2 \
    --tags=http-server,https-server,rtmp-server \
    --network-tier=STANDARD \
    --zone=europe-west1-b \
    --address=rtmp-hls-server-ip \
    --image-family cos-stable \
    --image-project cos-cloud \
    --metadata-from-file user-data=cloud-init.yml
