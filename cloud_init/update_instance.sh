#!/usr/bin/env bash

set -e
python parse.py
gcloud compute instances add-metadata rtmp-hls-server \
    --metadata-from-file=user-data=cloud-init.yml 
gcloud compute ssh rtmp-hls-server --zone=europe-west1-b \
    -- 'sudo /usr/share/cloud/rerun-cloudinit.sh && systemctl status rtmp-hls'