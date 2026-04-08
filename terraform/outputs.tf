output "environment_id" {
  value = confluent_environment.demo_env.id
}

output "kafka_cluster_endpoint" {
  value = confluent_kafka_cluster.basic_cluster.bootstrap_endpoint
}

# Kafka Credentials
output "kafka_api_key" {
  value = confluent_api_key.kafka_api_key.id
}

output "kafka_api_secret" {
  value     = confluent_api_key.kafka_api_key.secret
  sensitive = true
}

# Flink Credentials
output "flink_api_key" {
  value = confluent_api_key.flink_api_key.id
}

output "flink_api_secret" {
  value     = confluent_api_key.flink_api_key.secret
  sensitive = true
}

# Schema Registry Credentials
output "sr_endpoint" {
  value = data.confluent_schema_registry_cluster.sr_cluster.rest_endpoint
}

output "sr_api_key" {
  value = confluent_api_key.sr_api_key.id
}

output "sr_api_secret" {
  value     = confluent_api_key.sr_api_key.secret
  sensitive = true
}
