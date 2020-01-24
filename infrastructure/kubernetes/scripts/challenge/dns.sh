#!/bin/bash

set -Eeuo pipefail
DIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}")" )" >/dev/null && pwd )/../.."

if [ ! -f ~/.config/kctf/cluster.conf ]; then
    echo 'cluster config not found, please create or load it first'
    exit 1
fi
source ~/.config/kctf/cluster.conf

if [ $# != 1 ]; then
    echo 'missing challenge name'
    exit 1
fi

CHALLENGE_NAME=$1
CHALLENGE_DIR=$(readlink -f "${CHAL_DIR}/${CHALLENGE_NAME}")

pushd $CHALLENGE_DIR/config
if [ ! -z "${DOMAIN_NAME}" ]
then
    LB_IP=$($DIR/scripts/challenge/ip.sh "${CHALLENGE_NAME}")
    gcloud dns record-sets transaction start --zone="${CLUSTER_NAME}-dns-zone"
    gcloud dns record-sets transaction add --zone="${CLUSTER_NAME}-dns-zone" --ttl 30 --name "${CHALLENGE_NAME}.${DOMAIN_NAME}." --type A "${LB_IP}"
    gcloud dns record-sets transaction execute --zone="${CLUSTER_NAME}-dns-zone"
else
    echo "DOMAIN_NAME not defined. Run ./scripts/setup/config.sh"
fi

popd