provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  # https://github.com/hashicorp/terraform-provider-kubernetes/releases
  load_config_file = false

  host  = "https://${data.google_container_cluster.cluster_qsprod.endpoint}"
  token = data.google_client_config.current.access_token

  cluster_ca_certificate = base64decode(
    google_container_cluster.cluster_qsprod.master_auth[0].cluster_ca_certificate,
  )
}

