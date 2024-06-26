provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "arn:aws:eks:us-east-1:637423621713:cluster/csye7125" 
}

resource "kubernetes_namespace" "csye7125" {
    metadata {
        name = "cve-processor"
    }
}

resource "kubernetes_namespace" "kafka" {
    metadata {
        name = "kafka"
    }
}

resource "kubernetes_namespace" "cve-consumer" {
    metadata {
        name = "cve-consumer"
    }
}