# deploy-helm-gke-action

### Description

Configure and deploy a [Helm](https://helm.sh/) chart to [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine), decoding secrets using [sops](https://github.com/mozilla/sops).

### Using this action

1. Create a [secret in your repository](https://docs.github.com/en/actions/reference/encrypted-secrets) with the name `GKE_PROJECT`
2. Set up a [service account in Google Cloud console](https://console.cloud.google.com/iam-admin/serviceaccounts) with roles `Cloud KMS CryptoKey Decrypter`, `Kubernetes Engine Developer` and `Storage Admin` and download the data as JSON.
3. Create another secret, `GKE_SA_KEY` with the contents of the just saved JSON file.
4. Save below file as `.github/workflows/deploy.yml` and change it as needed.

```yaml
on:
  push: [main]

env:
  APP_NAME: my-app

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    env:
      DEPLOY_ENVIRONMENT: staging
    steps:
      -
        uses: actions/checkout@v2
      -
        uses: jmagnusson/deploy-helm-gke-action@v1
        with:
          docker-image-repo: eu.gcr.io/${{ secrets.GKE_PROJECT }}/${{ env.APP_NAME }}
          docker-image-tag: ${{ github.sha }}
          helm-release-name: ${{ env.APP_NAME }}
          helm-chart-path: ./charts/${{ env.APP_NAME }}
          helm-vars-folder: helm_vars/${{ env.DEPLOY_ENVIRONMENT }}
          gke-project: ${{ secrets.GKE_PROJECT }}
          gke-cluster: ${{ env.DEPLOY_ENVIRONMENT }}
          gke-zone: ${{ secrets.GKE_ZONE }}
          gke-sa-key: ${{ secrets.GKE_SA_KEY }}
```

### Inputs

| input | description | required | default |
|---|---|---|---|
| docker-image-repo | Docker image repository, e.g. `eu.gcr.io/abc123/my-app` | `true` | |
| docker-image-tag | Docker image tag, e.g. `v0.10.2`. Defaults to using the commit hash | `true` | `${{ github.sha }}` |
| helm-release-name | Name of the Helm release | `true` | |
| helm-chart-path | Where the Helm chart resides | `true` | |
| helm-vars-folder | Folder with Helm variable files. This folder must contain the file values.yaml, and optionally a sops-encrypted file named secrets.yaml. | `true` | `"helm_vars"` |
| helm-set | Additional helm values to set (corresponds to `helm upgrade --set`). Should have format KEY1=VAL1,KEY2=VAL2. | `false` | |
| helm-set-string | Additional helm string values to set (corresponds to `helm upgrade --set-string`). Should have format KEY1=VAL1,KEY2=VAL2. | `false` | |
| gke-project | The Google Cloud project | `true` | |
| gke-cluster | The name of the Google Cloud Kubernetes cluster | `true` | |
| gke-zone | The zone of the Kubernetes cluster | `true` | |
| gke-sa-key | A Google Cloud service account key (JSON-format) which has the required permissions. | `true` | |
