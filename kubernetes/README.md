This is sample repository for running Google Cloud Deploy in GKE cluster.

## prerequisities
- Terraform (v0.15.5 or higher)
- Cloud SDK (358.0.0 or higher)
## process

### 0. create k8s cluster

```
cd ./terraform
touch ./vars/terraform.tfvars
```

```diff
// set gcp_project_id in terraform.tfvars
+ project_id = "<gcp_project_id>"
```

```
terraform apply -var-file=./vars/terraform.tfvars
```

### 1. create deploy pipeline

```
cd ./manifests
gcloud beta deploy apply --file clouddeploy.yaml --region=us-central1 --project=<gcp_project_id>
```

```
~/w/t/t/g/k/c/manifests ❯❯❯ gcloud beta deploy apply --file clouddeploy.yaml --region=us-central1 --project=<gcp_project_id>

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
~/w/t/t/g/k/c/manifests ❯❯❯ gcloud beta deploy releases create test-release-001 --project=<gcp_project_id> --region=us-central1 --delivery-pipeline=my-demo-app-1

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

```
~/w/t/t/g/k/c/terraform ❯❯❯ gcloud container clusters get-credentials quickstart-cluster-qsdev --zone us-central1-f --project <gcp_project_id>
Fetching cluster endpoint and auth data.
kubeconfig entry generated for quickstart-cluster-qsdev.
~/w/t/t/g/k/c/terraform ❯❯❯ k get po
NAME                                READY   STATUS    RESTARTS   AGE
staging-test-app-68f8445c74-bhj2p   1/1     Running   0          3m4s
```

### 3. promote release

```
~/w/t/t/g/k/c/manifests ❯❯❯ gcloud beta deploy releases promote --release=test-release-001 --delivery-pipeline=my-demo-app-1 --region=us-central1 --project=<gcp_project_id>

Promoting release test-release-001 to target qsprod.

Do you want to continue (Y/n)?  Y

Creating rollout projects/<gcp_project_id>/locations/us-central1/deliveryPipelines/my-demo-app-1/
releases/test-release-001/rollouts/test-release-001-to-qsprod-0001 in target qsprod...done.  
```

```
~/w/t/t/g/k/c/terraform ❯❯❯ k describe deployment
Name:                   production-test-app
Namespace:              default
CreationTimestamp:      Sun, 26 Sep 2021 00:02:01 +0900
Labels:                 app=test
                        env=prd
Annotations:            deployment.kubernetes.io/revision: 1
                        kubectl.kubernetes.io/last-applied-configuration:
                          {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"labels":{"app":"test","env":"prd"},"name":"production-test-app",...
Selector:               app=test
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=test
  Containers:
   test-echoserver:
    Image:        k8s.gcr.io/echoserver:1.5
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   production-test-app-5d66fdddb4 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  103s  deployment-controller  Scaled up replica set production-test-app-5d66fdddb4 to 1
```

## reference
- https://cloud.google.com/deploy/docs/quickstart-basic?hl=ja