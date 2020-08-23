#!/usr/bin/env bash

set -ex
INSTANCE_NAME="${INSTANCE_NAME:-"$(curl -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/name')"}"
INSTANCE_ZONE="${INSTANCE_ZONE:-"$(curl -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/instance/zone')"}"
INSTANCE_PROJECT="${INSTANCE_PROJECT:-"$(curl -H 'Metadata-Flavor: Google' 'http://metadata.google.internal/computeMetadata/v1/project/project-id')"}"
INSTANCE_ZONE="${INSTANCE_ZONE##*/}"

INSTANCE_URI="projects/${INSTANCE_PROJECT}/zones/${INSTANCE_ZONE}/instances/${INSTANCE_NAME}"

ATTRIBUTES="$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/)"
if echo "$ATTRIBUTES" | grep 'user-data'
then
    echo "Already installed"
    if echo "$ATTRIBUTES" | grep 'auto-update' > /dev/null \
        && [[ "$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/auto-updates)" == "yes" ]] \
        && diff -b "<(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/user-data)" cloud-init.yml
    then
        echo "Updating user-data to latest version..."
    else
        echo "Nothing to do"
        exit 0
    fi
fi

gcloud compute instances update-container "$INSTANCE_URI" --container-restart-policy=never 

gcloud compute instances add-metadata "$INSTANCE_URI" \
    --metadata-from-file=user-data=cloud-init.yml --metadata=auto-updates=yes,publish-password="$(head -c 8 /dev/urandom | base64 | tr -Cd '[:alnum:]')",play-password=abc

gcloud compute instances add-tags "$INSTANCE_URI" --tags=https-server,http-server,rtmp-server

gcloud compute firewall-rules list | grep default-allow-rtmp || {
    gcloud compute firewall-rules create --allow=tcp:1935 --source-ranges='0.0.0.0/0' --target-tags=rtmp-server --priority=1000
}