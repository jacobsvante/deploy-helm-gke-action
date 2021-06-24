# deploy-helm-gke-action

### Description

Configure and deploy a Helm chart to Google Kubernetes Engine,
decoding secrets using sops.

| input | description | required | default |
|---|---|---|---|
| docker-image-repo | description: Docker image repository, e.g. `eu.gcr.io/abc123/my-app` | `true` | |
| docker-image-tag | description: Docker image tag, e.g. `v0.10.2`. Defaults to using the commit hash | `true` | `${{ github.sha }}` |
| helm-release-name | description: Name of the Helm release | `true` | |
| helm-chart-path | description: Where the Helm chart resides | `true` | |
| helm-vars-folder | description: Folder with Helm variable files. This folder must contain the file values.yaml, and optionally a sops-encrypted file named secrets.yaml. | `true` | `"helm_vars"` |
| gke-project | description: The Google Cloud project | `true` | |
| gke-cluster | description: The name of the Google Cloud Kubernetes cluster | `true` | |
| gke-zone | description: The zone of the Kubernetes cluster | `true` | |
| gke-sa-key | description: A Google Cloud service account key (JSON-format) which has the required permissions. | `true` | |
