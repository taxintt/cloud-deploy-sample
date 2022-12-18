## process

### 1. create deploy pipeline (Terraform)

```tf
# set project_id = "<project_id>"
touch dev.tfvars

make apply
```

### 2. create release (change image tag or digest)
Trigger: commit to develop branch

Set up compute engine service account
ref: https://cloud.google.com/deploy/docs/deploy-app-run

And, set these secrets as github actions secrets

- `GCP_CREDENTIALS`
  - `cat your-service-key.json | base64 | pbcopy`
- `GCP_PROJECT_ID`


### 3. promote release
Trigger: PR merge