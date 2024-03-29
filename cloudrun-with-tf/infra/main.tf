terraform {
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.46.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.46.0"
    }
  }
}


#
# cloud deploy
#
resource "google_clouddeploy_delivery_pipeline" "primary" {
    provider = google-beta
    project  = var.project_id
    location = var.region
    name     = "test-app-backend"

    description = "test app backend pipeline"

    serial_pipeline {
        stages {
            profiles  = []
            target_id = "run-qsdev"
        }

        stages {
            profiles  = []
            # WARN: use target name 
            # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/clouddeploy_delivery_pipeline#target_id
            target_id = "run-qsprod"
        }
    }
}

resource "google_clouddeploy_target" "dev" {
    provider = google-beta
    project  = var.project_id
    location = var.region
    name     = "run-qsdev"

    require_approval = false

    # annotations = {
    #     my_first_annotation = "example-annotation-1"
    #     my_second_annotation = "example-annotation-2"
    # }

    description = "Cloud Run development service - dev"

    # https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/clouddeploy_target#execution_configs
    execution_configs {
        usages            = ["RENDER", "DEPLOY"]
        execution_timeout = "3600s"
        service_account = google_service_account.clouddeploy_backend.email
    }

    # TODO: specify the project for dev environment
    run {
        location = "projects/${var.project_id}/locations/${var.region}"
    }
}

resource "google_clouddeploy_target" "prod" {
    provider = google-beta
    project  = var.project_id
    location = var.region
    name     = "run-qsprod"

    require_approval = false

    # annotations = {
    #     my_first_annotation = "example-annotation-1"
    #     my_second_annotation = "example-annotation-2"
    # }

    description = "Cloud Run development service - dev"

    execution_configs {
        usages            = ["RENDER", "DEPLOY"]
        execution_timeout = "3600s"
        service_account = google_service_account.clouddeploy_backend.email
    }

    # TODO: specify the project for dev environment
    run {
        location = "projects/${var.project_id}/locations/${var.region}"
    }
}

#
# cloud run
#
resource "google_cloud_run_service" "sample" {
  provider = google-beta
  project  = var.project_id

  name     = "sample"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello:latest"
      }
    }
  }
}

#
# IAM service account (cloud deploy)
# 
resource "google_service_account" "clouddeploy_backend" {
  account_id   = "cloud-deploy-backend"
  project      = var.project_id
  display_name = "cloud-deploy-backend"
}

resource "google_service_account_key" "clouddeploy_backend" {
  service_account_id = google_service_account.clouddeploy_backend.id
}

resource "google_secret_manager_secret" "sa_key" {
  project = var.project_id

  secret_id = "cloud-deploy-backend-sa-key"
  replication {
    user_managed {
        replicas {
            location = var.region
        }
    }
  }
}

resource "google_secret_manager_secret_version" "sa_key" {
  secret = google_secret_manager_secret.sa_key.id
  secret_data = base64decode(google_service_account_key.clouddeploy_backend.private_key)
}

resource "google_project_iam_member" "clouddeploy_backend_is_clouddeploy_job_runner" {
  project = var.project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

resource "google_project_iam_member" "clouddeploy_backend_is_clouddeploy_releaser" {
  project = var.project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

resource "google_project_iam_member" "clouddeploy_backend_is_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

# TODO: we have to grant role for source bucket that is created randomly like 2238c8c34bc44369acb308bc661fd899_clouddeploy
# Role for creating and accessing GCS bucket
resource "google_project_iam_member" "clouddeploy_backend_is_gcs_bucket_creator" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

resource "google_service_account_iam_member" "clouddeploy_backend_is_service_account_user" {
  service_account_id = google_service_account.clouddeploy_backend.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

#
# IAM service account (cloud run)
# 
resource "google_service_account" "run_backend" {
  account_id   = "cloud-run-backend"
  project      = var.project_id
  display_name = "cloud-run-backend"
}

resource "google_project_iam_member" "run_backend_is_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.run_backend.email}"
}