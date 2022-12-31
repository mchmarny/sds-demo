#!/bin/bash

DIR="$(dirname "$0")"
. "${DIR}/config"

set -o errexit
set -o pipefail

# setup vulnerability and builder attestors
setup/attestor $GCB_ATTESTOR_ID
setup/attestor $SBOM_ATTESTOR_ID
setup/attestor $VULN_ATTESTOR_ID

# setup policy 
gcloud container binauthz policy import policy/attestor-policy.yaml

# list attestors
gcloud container binauthz attestors list

# list attestation 
gcloud container binauthz attestations list \
    --attestor=$VULN_ATTESTOR_ID \
    --attestor-project=$PROJECT_ID