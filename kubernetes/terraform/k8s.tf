data "google_client_config" "current" {}

# generating a kubeconfig entry:
# gcloud container clusters get-credentials tf-gke --project <project_id>
resource "google_container_cluster" "cluster_qsdev" {
  name     = "quickstart-cluster-qsdev"
  project  = var.project_id
  location = var.zone

  remove_default_node_pool = true
  min_master_version       = var.node_version
  initial_node_count       = 1

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
  # https://github.com/hashicorp/terraform-provider-google/issues/3966
  provider = google-beta

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#monitoring_service
  # https://cloud.google.com/kubernetes-engine/docs/how-to/small-cluster-tuning?hl=ja#kubernetes-engine-monitoring
  monitoring_service = "none"

  addons_config {
    http_load_balancing {
      disabled = true
    }
    # To use the Istio CNI feature, the network-policy GKE feature must be enabled in the cluster.
    # https://istio.io/latest/docs/setup/platform-setup/gke/
    network_policy_config {
      disabled = false
    }
    istio_config {
      disabled = true
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform#vpc-native-clusters
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  depends_on = [
    google_service_account.least-privilege-sa-for-gke,
  ]
}

resource "google_container_node_pool" "cluster_qsdev_preemptible_nodes" {
  name     = "node-pool-for-tf-gke"
  cluster  = google_container_cluster.cluster_qsdev.name
  project  = google_container_cluster.cluster_qsdev.project
  location = google_container_cluster.cluster_qsdev.location

  node_count = 3

  # https://blog.yukirii.dev/create-gke-with-least-privilege-sa-using-terraform/
  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = "least-privilege-sa-for-gke@${var.project_id}.iam.gserviceaccount.com"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = ["istio"]
  }

  depends_on = [
    google_service_account.least-privilege-sa-for-gke,
  ]
}


resource "google_container_cluster" "cluster_qsprod" {
  name     = "quickstart-cluster-qsprod"
  project  = var.project_id
  location = var.zone

  remove_default_node_pool = true
  min_master_version       = var.node_version
  initial_node_count       = 1

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_versions
  # https://github.com/hashicorp/terraform-provider-google/issues/3966
  provider = google-beta

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#monitoring_service
  # https://cloud.google.com/kubernetes-engine/docs/how-to/small-cluster-tuning?hl=ja#kubernetes-engine-monitoring
  monitoring_service = "none"

  addons_config {
    http_load_balancing {
      disabled = true
    }
    # To use the Istio CNI feature, the network-policy GKE feature must be enabled in the cluster.
    # https://istio.io/latest/docs/setup/platform-setup/gke/
    network_policy_config {
      disabled = false
    }
    istio_config {
      disabled = true
    }
  }

  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform#vpc-native-clusters
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }

  depends_on = [
    google_service_account.least-privilege-sa-for-gke,
  ]
}

resource "google_container_node_pool" "cluster_qsprod_preemptible_nodes" {
  name     = "node-pool-for-tf-gke"
  cluster  = google_container_cluster.cluster_qsprod.name
  project  = google_container_cluster.cluster_qsprod.project
  location = google_container_cluster.cluster_qsprod.location

  node_count = 3

  # https://blog.yukirii.dev/create-gke-with-least-privilege-sa-using-terraform/
  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = "least-privilege-sa-for-gke@${var.project_id}.iam.gserviceaccount.com"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    tags = ["istio"]
  }

  depends_on = [
    google_service_account.least-privilege-sa-for-gke,
  ]
}

