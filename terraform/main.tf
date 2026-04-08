terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.0.0"
    }
  }
}

provider "confluent" {

  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret

}

# 1. Environment & Stream Governance
resource "confluent_environment" "demo_env" {
  display_name = "Demo-Environment"
  stream_governance {
    package = "ESSENTIALS"
  }
}

# 2. Kafka Cluster (AWS us-east-2)
resource "confluent_kafka_cluster" "basic_cluster" {
  display_name = "demo-kafka-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "us-east-2"
  basic {}
  environment { id = confluent_environment.demo_env.id }
}

# 3. Flink Compute Pool
resource "confluent_flink_compute_pool" "flink_pool" {
  display_name = "demo-flink-pool"
  cloud        = "AWS"
  region       = "us-east-2"
  max_cfu      = 5
  environment { id = confluent_environment.demo_env.id }
}

# 4. Service Account
resource "confluent_service_account" "app_manager" {
  display_name = "app-manager-sa"
}

# --------------------------------------------------------
# 5. ROLE BINDINGS (The "Permissions" Layer)
# --------------------------------------------------------

# Grant Cluster Admin on the Kafka Cluster
resource "confluent_role_binding" "kafka_cluster_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic_cluster.rbac_crn
}

# Grant Schema Registry Read/Write
resource "confluent_role_binding" "sr_resource_owner" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${data.confluent_schema_registry_cluster.sr_cluster.resource_name}/subject=*"
}

# Grant Flink Admin on the Environment
resource "confluent_role_binding" "flink_admin" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "FlinkAdmin"
  crn_pattern = confluent_environment.demo_env.resource_name
}

# --------------------------------------------------------
# 6. API KEYS
# --------------------------------------------------------

# Kafka API Key
resource "confluent_api_key" "kafka_api_key" {
  display_name = "kafka-api-key"
  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.basic_cluster.id
    api_version = confluent_kafka_cluster.basic_cluster.api_version
    kind        = confluent_kafka_cluster.basic_cluster.kind
    environment { id = confluent_environment.demo_env.id }
  }
}

# Schema Registry API Key
data "confluent_schema_registry_cluster" "sr_cluster" {
  environment { id = confluent_environment.demo_env.id }
}

resource "confluent_api_key" "sr_api_key" {
  display_name = "sr-api-key"
  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }
  managed_resource {
    id          = data.confluent_schema_registry_cluster.sr_cluster.id
    api_version = data.confluent_schema_registry_cluster.sr_cluster.api_version
    kind        = data.confluent_schema_registry_cluster.sr_cluster.kind
    environment { id = confluent_environment.demo_env.id }
  }
}

data "confluent_flink_region" "example" {
  cloud   = "AWS"
  region  = "us-east-1"
}

output "example" {
  value = data.confluent_flink_region.example
}

# Flink API Key
resource "confluent_api_key" "flink_api_key" {
  display_name = "flink-api-key"
  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }
  managed_resource {
    id          = data.confluent_flink_region.example.id
    api_version = data.confluent_flink_region.example.api_version
    kind        = data.confluent_flink_region.example.kind
    environment { id = confluent_environment.demo_env.id }
  }
}
