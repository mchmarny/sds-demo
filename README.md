# GCP CI/CD security demo

This repo demonstrates a security focused CI/CD pipeline for GKE with Google Cloud tools Cloud Build, Binary Authorization, Artifact Registry, Container Analysis, and Google Cloud Deploy. The example app is a simple containerized Maven example app with Kustomize overlays for Kubernetes manifest rendering!

[![Google Cloud Software Supply Chain Security Demo Flow](https://user-images.githubusercontent.com/76225123/170594159-cae11896-5ac1-473c-8d71-924a8d059155.png)](https://user-images.githubusercontent.com/76225123/170594159-cae11896-5ac1-473c-8d71-924a8d059155.png)

## Setup 

Configure local resources

```shell
setup/init
```

Create GCP resources 

```shell
setup/pipeline
setup/cluster
```

Wait fro cluster to be created

```shell
watch gcloud beta container clusters list --filter="resourceLabels.demo:build"
```

