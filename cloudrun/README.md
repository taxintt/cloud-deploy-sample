This is sample repository for running Google Cloud Deploy in Cloud run.

## prerequisities
- Terraform (v0.15.5 or higher)
- Cloud SDK (358.0.0 or higher)

## process

### 1. create deploy pipeline

```
gcloud beta deploy apply --file clouddeploy.yaml --region=us-central1 --project=<gcp_project_id>
```

```
gcloud beta deploy apply --file clouddeploy.yaml --region=us-central1 --project=<gcp_project_id>

Waiting for the operation on resource projects/<gcp_project_id>/locations/us-central1/deliveryPip
elines/my-demo-app-1...done.                                                                          
Created Cloud Deploy resource: projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-demo-app-1.
Waiting for the operation on resource projects/<gcp_project_id>/locations/us-central1/targets/qsd
ev...done.                                                                                            
Created Cloud Deploy resource: projects/<gcp_project_id>/locations/us-central1/targets/qsdev.
Waiting for the operation on resource projects/<gcp_project_id>/locations/us-central1/targets/qsp
rod...done.                                                                                           
Created Cloud Deploy resource: projects/<gcp_project_id>/locations/us-central1/targets/qsprod.
```

### 2. create release (change image tag or digest)

```
gcloud beta deploy releases create test-release-001 \
  --project=<gcp_project_id> \
  --delivery-pipeline=my-run-demo-app-1 \
  --region=us-central1 \
  --images=my-app-image=gcr.io/cloudrun/hello
```

```
gcloud beta deploy releases create test-release-001 \
  --project=<gcp_project_id> \
  --delivery-pipeline=my-run-demo-app-1 \
  --region=us-central1 \
  --images=my-app-image=gcr.io/cloudrun/hello
Creating temporary tarball archive of 5 file(s) totalling 3.2 KiB before compression.
Uploading tarball of [.] to [gs://64a75546710848be813fbd62bf758b5a_clouddeploy/source/1663152727.323632-06b9ae7790f943b89bedfffbe1f6c3d5.tgz]
Waiting for operation [operation-1663152730098-5e8a0ebaf4af8-9d018783-6bd65519]...done.                                                                                                                                             
Created Cloud Deploy release test-release-001.
Creating rollout projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-run-demo-app-1/releases/test-release-001/rollouts/test-release-001-to-run-qsdev-0001 in target run-qsdev
Waiting for rollout creation operation to complete...done.    
```

### 3. promote release

```
gcloud beta deploy releases promote --release=test-release-001 \
  --project=<gcp_project_id> \
  --delivery-pipeline=my-run-demo-app-1 \
  --region=us-central1
```

```
❯ gcloud beta deploy releases promote --release=test-release-001 \
  --project=<gcp_project_id> \
  --delivery-pipeline=my-run-demo-app-1 \
  --region=us-central1

Promoting release test-release-001 to target run-qsprod.

Do you want to continue (Y/n)?  Y

Creating rollout projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-run-demo-app-1/releases/test-release-001/rollouts/test-release-001-to-run-qsprod-0001 in target run-qsprod
Waiting for rollout creation operation to complete...done.  
```

## reference
- https://cloud.google.com/deploy/docs/deploy-app-run