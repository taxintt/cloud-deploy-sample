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
gcloud beta deploy releases create my-release --delivery-pipeline=my-pipeline --region=us-central1 --to-target=prod
```

```
gcloud beta deploy releases create test-release-001 --project=<gcp_project_id> --region=us-central1 --delivery-pipeline=my-demo-app-1

Creating temporary tarball archive of 10 file(s) totalling 10.8 KiB before compression.
Uploading tarball of [.] to [gs://<gcp_project_id>_clouddeploy/source/1632576641.742005-1e4ff4cdf25f4a3088e734594716627a.tgz]
Waiting for operation [operation-1632576644579-5ccd1def8005e-e9fc5844-a6860ec5]...done.               
Created Cloud Deploy release test-release-001.
API [cloudresourcemanager.googleapis.com] not enabled on project 
[xxx]. Would you like to enable and retry (this will take a 
few minutes)? (y/N)?  y

Enabling service [cloudresourcemanager.googleapis.com] on project [xxx]...
Operation "operations/acf.p2-xxx-b1ce3c52-4e1a-46c8-90b9-7f6e4043f9ff" finished successfully.
Creating rollout projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-demo-app-1/
releases/test-release-001/rollouts/test-release-001-to-qsdev-0001 in target qsdev...done.    
```

### 3. promote release

```
gcloud beta deploy releases promote --release=test-release-001 --delivery-pipeline=my-demo-app-1 --region=us-central1 --project=<gcp_project_id>

Promoting release test-release-001 to target qsprod.

Do you want to continue (Y/n)?  Y

Creating rollout projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-demo-app-1/
releases/test-release-001/rollouts/test-release-001-to-qsprod-0001 in target qsprod...done.  
```

## reference
- https://cloud.google.com/deploy/docs/deploy-app-run