resource "google_clouddeploy_delivery_pipeline" "primary" {
    provider = google-beta
    project  = var.project_id
    location = "asia-northeast1"
    name     = "test-app-backend"

    description = "test app backend pipeline"

    serial_pipeline {
        stages {
            profiles  = []
            target_id = google_clouddeploy_target.dev.target_id
        }

        stages {
            profiles  = []
            target_id = google_clouddeploy_target.prod.target_id
        }
    }
}

resource "google_clouddeploy_target" "dev" {
    provider = google-beta
    project  = var.project_id
    location = "us-west1"
    name     = "run-qsdev"

    require_approval = false

    # annotations = {
    #     my_first_annotation = "example-annotation-1"
    #     my_second_annotation = "example-annotation-2"
    # }

    description = "Cloud Run development service - dev"

    execution_configs {
        usages            = ["RENDER", "DEPLOY"]
        execution_timeout = "3600s"
    }

    run {
        location = "projects/my-project-name/locations/us-west1"
    }
}

resource "google_clouddeploy_target" "prod" {
    provider = google-beta
    project  = var.project_id
    location = "us-west1"
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
    }

    run {
        location = "projects/my-project-name/locations/us-west1"
    }
}

#
# IAM service account
# 
resource "google_service_account" "clouddeploy_backend" {
  account_id   = "cloud-deploy-backend"
  project      = var.project_id
  display_name = "cloud-deploy-backend"
}

resource "google_project_iam_member" "clouddeploy_backend_is_clouddeploy_job_runner" {
  project = var.project_id
  role    = "roles/clouddeploy.jobRunner"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

resource "google_project_iam_member" "clouddeploy_backend_is_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}

resource "google_service_account_iam_member" "clouddeploy_backend_is_ekilog_backend_user" {
  service_account_id = google_service_account.ekilog_backend.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.clouddeploy_backend.email}"
}
