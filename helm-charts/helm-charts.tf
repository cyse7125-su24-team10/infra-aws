provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}

resource "helm_release" "kafka_chart" {
    name      = "kafka"
    chart = "../charts/kafka"
    wait = false
    namespace = "kafka"
}

resource "helm_release" "postgres_chart" {
    name      = "postgresql"
    chart = "../charts/bitnami-postgres"
    wait = false
    namespace = "cve-consumer"
}

# resource "helm_release" "cve_consumer_chart" {
#     name      = "cve-consumer"
#     chart = "../charts/cve-consumer"
#     wait = false
#     namespace = "cve-consumer"
# }

resource "helm_release" "cve_processor_chart" {
    name      = "cve-processor"
    chart = "../charts/cve-processor"
    wait = false
    namespace = "cve-processor"
}

