# GCP CI/CD security demo

> This go demo is based on the [secure maven build demo](https://github.com/vszal/secure-cicd-maven) by [@vszal](https://github.com/vszal)

This repo bootstraps a CI/CD pipeline on Google Cloud. That pipelines combines the following services to demonstrate policy controls for container attestation and build provenance for workloads deployed into GKE

* Cloud Build with GitHub repo trigger on tag push
* Binary Authorization for policy-based deployment control to attest that images:
  * are built by Cloud Build
  * have no known vulnerability (been scanned and signed using key from KMS)
* Artifact Registry for image storage and management
* Container Analysis for vulnerability scanning and to manage meta-data
* Cloud Deploy to manage the entire delivery pipeline 

> For example of type of an app that uses this pipeline see [hello](https://github.com/mchmarny/hello).

## Requirements 

* [gcloud](https://cloud.google.com/sdk/docs/install)
* [jq](https://stedolan.github.io/jq/download/)

## Setup 

To deploy this pipeline into your GCP project, starts with configuring the local resources:

```shell
setup/init
```

Create GCP resources 

```shell
setup/pipeline
setup/analysis
setup/cluster
```

Wait for cluster to be created

```shell
gcloud container clusters list --filter="resourceLabels.demo:build"
```

## Cleanup 

```shell
setup/delete
```

## Disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.