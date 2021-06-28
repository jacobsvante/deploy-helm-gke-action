#!/bin/sh

set -e

missing_var() {
    echo "Variable $1 needs to be set"
    exit 1
}

DOCKER_IMAGE_REPO="$(printenv INPUT_DOCKER-IMAGE-REPO)" || missing_var "INPUT_DOCKER-IMAGE-REPO"
DOCKER_IMAGE_TAG="$(printenv INPUT_DOCKER-IMAGE-TAG)" || missing_var "INPUT_DOCKER-IMAGE-TAG"
HELM_RELEASE_NAME="$(printenv INPUT_HELM-RELEASE-NAME)" || missing_var "INPUT_HELM-RELEASE-NAME"
HELM_CHART_PATH="$(printenv INPUT_HELM-CHART-PATH)" || missing_var "INPUT_HELM-CHART-PATH"
HELM_VARS_FOLDER="$(printenv INPUT_HELM-VARS-FOLDER)" || missing_var "INPUT_HELM-VARS-FOLDER"
GKE_PROJECT="$(printenv INPUT_GKE-PROJECT)" || missing_var "INPUT_GKE-PROJECT"
GKE_CLUSTER="$(printenv INPUT_GKE-CLUSTER)" || missing_var "INPUT_GKE-CLUSTER"
GKE_ZONE="$(printenv INPUT_GKE-ZONE)" || missing_var "INPUT_GKE-ZONE"
GKE_SA_KEY="$(printenv INPUT_GKE-SA-KEY)" || missing_var "INPUT_GKE-SA-KEY"

echo "DOCKER_IMAGE_REPO=$DOCKER_IMAGE_REPO"
echo "DOCKER_IMAGE_TAG=$DOCKER_IMAGE_TAG"
echo "HELM_RELEASE_NAME=$HELM_RELEASE_NAME"
echo "HELM_CHART_PATH=$HELM_CHART_PATH"
echo "HELM_VARS_FOLDER=$HELM_VARS_FOLDER"
echo "GKE_PROJECT=$GKE_PROJECT"
echo "GKE_CLUSTER=$GKE_CLUSTER"
echo "GKE_ZONE=$GKE_ZONE"
echo "GKE_SA_KEY=$GKE_SA_KEY"

export KUBECONFIG=/kubeconfig.yaml

echo $GKE_SA_KEY \
    | gke-kubeconfig -cluster $GKE_CLUSTER -location $GKE_ZONE -project $GKE_PROJECT \
    > $KUBECONFIG
chmod 400 $KUBECONFIG

echo $GKE_SA_KEY > $HOME/gke-sa-key.json && \
    GOOGLE_APPLICATION_CREDENTIALS=$HOME/gke-sa-key.json \
    sops -d $HELM_VARS_FOLDER/secrets.yaml \
    > $HELM_VARS_FOLDER/secrets.yaml.dec \
    || echo '{}' > $HELM_VARS_FOLDER/secrets.yaml.dec

helm upgrade \
    --atomic \
    --install \
    --values $HELM_VARS_FOLDER/values.yaml \
    --values $HELM_VARS_FOLDER/secrets.yaml.dec \
    --set-string image.repository=$DOCKER_IMAGE_REPO \
    --set-string image.tag=$DOCKER_IMAGE_TAG \
    $HELM_RELEASE_NAME \
    $HELM_CHART_PATH
