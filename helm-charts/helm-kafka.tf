provider "helm" {
    kubernetes {
        config_path = "~/.kube/config"
    }
}

resource "helm_release" "kafka_chart" {
    name      = "kafka"
    chart = "/Users/vinaykumarchelpuri/Documents/adv_cloud/helm-kafka/kafka"
    wait = false
    namespace = "kafka"
}