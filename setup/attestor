#!/bin/bash

DIR="$(dirname "$0")"
. "${DIR}/config"

set -o errexit
set -o pipefail

ATTESTOR_ID=$1

echo "Creating attestor ${ATTESTOR_ID}"

# create attestation
curl "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/?noteId=${ATTESTOR_ID}-note" \
  --request "POST" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${PROJECT_ID}" \
  --data-binary @- <<EOF
    {
      "name": "projects/${PROJECT_ID}/notes/${ATTESTOR_ID}-note",
      "attestation": {
        "hint": {
          "human_readable_name": "${ATTESTOR_ID} note"
        }
      }
    }
EOF

# get notes resource location
export NOTE_LOCATION=$(curl -s "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/${ATTESTOR_ID}-note" \
  --request "GET" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${PROJECT_ID}" \
  | jq --raw-output '.name')


# set policy for the note
curl "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/${ATTESTOR_ID}-note:setIamPolicy" \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --header "X-Goog-User-Project: ${PROJECT_ID}" \
  --data-binary @- <<EOF
    {
      "resource": "projects/${PROJECT_ID}/notes/${ATTESTOR_ID}-note",
      "policy": {
        "bindings": [
          {
            "role": "roles/containeranalysis.notes.occurrences.viewer",
            "members": [
              "serviceAccount:${CLOUD_BUILD_SA_EMAIL}"
            ]
          },
          {
            "role": "roles/containeranalysis.notes.attacher",
            "members": [
              "serviceAccount:${CLOUD_BUILD_SA_EMAIL}"
            ]
          }
        ]
      }
    }
EOF

gcloud container binauthz attestors create $ATTESTOR_ID \
  --project $PROJECT_ID \
  --attestation-authority-note-project $PROJECT_ID \
  --attestation-authority-note "${ATTESTOR_ID}-note" \
  --description "${ATTESTOR_ID} attestor"

gcloud beta container binauthz attestors public-keys add \
  --project $PROJECT_ID \
  --attestor $ATTESTOR_ID \
  --keyversion "1" \
  --keyversion-key $KMS_KEY_NAME \
  --keyversion-keyring $KMS_RING_NAME \
  --keyversion-location $REGION \
  --keyversion-project $PROJECT_ID

gcloud container binauthz attestors add-iam-policy-binding $ATTESTOR_ID \
  --project $PROJECT_ID \
  --member "serviceAccount:${CLOUD_BUILD_SA_EMAIL}" \
  --role "roles/binaryauthorization.attestorsViewer"

gcloud kms keys add-iam-policy-binding $KMS_KEY_NAME \
  --project $PROJECT_ID \
  --location $REGION \
  --keyring $KMS_RING_NAME \
  --member "serviceAccount:${CLOUD_BUILD_SA_EMAIL}" \
  --role "roles/cloudkms.signerVerifier"

echo "Attestor ${ATTESTOR_ID} configured."