# GCP CI/CD security demo

> This go demo is based on the [secure maven build demo](https://github.com/vszal/secure-cicd-maven) by [@vszal](https://github.com/vszal)

This repo bootstraps a CI/CD pipeline on Google Cloud. That pipelines combines the following services to demonstrate policy controls for container attestation, and image provenance for workloads deployed into GKE:

* Cloud Build with GitHub repo trigger on push of tag
* Static code vulnerability scan using Snyk 
* Binary Authorization for policy-based deployment control to attest that resulting images:
  * are built by Cloud Build
  * have no known vulnerability (been scanned and signed using key from KMS)
* Artifact Registry for image storage and management
* Container analysis for vulnerability and to meta-data management 
* Cloud Deploy to manage the entire delivery pipeline 
* GKE security posture dashboard with Configuration concerns

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

## Demo

Get cluster credentials:

```shell
gcloud container clusters get-credentials demo-test
```

### Attestation Validation

* Deploy locally build image 

```shell
kubectl apple -f https://raw.githubusercontent.com/mchmarny/hello/main/examples/deploy-docker.yaml
```

* Navigate to GKE [workloads](https://console.cloud.google.com/kubernetes/workload/overview), and show how `hello2` failed to deploy due to lack of attestation (use cluster/namespace filters)
* Navigate to Security Policy and show [BinAuth Policy](https://console.cloud.google.com/security/binary-authorization/policy) rules
  * Vulnerability attestation (scanned and signed with KMS key)
  * Built in Cloud Build (attested with KMS key signature)
  * Show dry run and images exempt option on policy as a means to incremental rollout

### Build on Tag (end-to-end)

* Show delivery pipeline config `clouddeploy.yaml`
  * And deployed `gcloud deploy delivery-pipelines list --region=us-west1`
* Use [demo app repo](https://github.com/mchmarny/hello) (may need to change repo source if cloning)
* Make some code change (e.g. edit API message in `route.go`, and bump version number in `.version`)
* Git add, commit, push in VS Code
* Git tag and push `make tag`
* Navigate to Cloud Build [triggers](https://console.cloud.google.com/cloud-build/triggers)
  * Push on tag (pattern)
  * Back in code, review config [cloudbuild.yaml](https://github.com/mchmarny/hello/blob/main/cloudbuild.yaml)
* Navigate to Cloud Build [builds](https://console.cloud.google.com/cloud-build/builds) in UI
  * Drill on active build 
  * Review steps (test, build, publish, scan, sign, release)
  * On Build Summary, show Build Artifacts > Image security insights ([SLSA Build Level 3](https://slsa.dev/spec/v0.1/levels))
* Navigate to Cloud Deploy [pipelines](https://console.cloud.google.com/deploy/delivery-pipelines)
  * Drill into `deploy-demo-pipeline`
  * Show 2 environments (test, prod)
  * Drill into the latest release 
* Navigate to GKE [workloads](https://console.cloud.google.com/kubernetes/workload/overview)
  * Drill into `hello` (note `hello2` erred due to lack of attestation)
  * Navigate to exposed service (`/api/ping`) and show version
* Back to Cloud Deploy [pipelines](https://console.cloud.google.com/deploy/delivery-pipelines) 
  * Show promotion and approval with manifest diffs and annotation comp (show more)
* Show GKE [Security Posture](https://console.cloud.google.com/kubernetes/security/dashboard)

## Cleanup 

```shell
setup/delete
```

## Disclaimer

This is my personal project and it does not represent my employer. While I do my best to ensure that everything works, I take no responsibility for issues caused by this code.