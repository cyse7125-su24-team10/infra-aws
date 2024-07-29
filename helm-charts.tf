

resource "kubernetes_namespace" "cve-processor" {
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

resource "kubernetes_namespace" "eks-autoscaler" {
    metadata {
        name = "eks-autoscaler"
    }
}

resource "kubernetes_namespace" "cve-operator" {
    metadata {
        name = "cve-operator"
    }
}

resource "kubernetes_namespace" "cloudwatch" {
    metadata {
        name = "amazon-cloudwatch"
    }
  
}
resource "helm_release" "kafka_chart" {
    name      = "kafka"
    chart = "./charts/kafka"
    wait = false
    namespace = "kafka"
    values = [
        "${file("./values/kafka-values.yaml")}"
    ]
    depends_on = [ module.eks, kubernetes_namespace.kafka ]
}

resource "helm_release" "postgres_chart" {
    name      = "postgresql"
    chart = "./charts/bitnami-postgres"
    wait = false
    namespace = "cve-consumer"
    values = [
        "${file("./values/postgres-values.yaml")}"
    ]
    depends_on = [ module.eks, kubernetes_namespace.cve-consumer ]
}

resource "helm_release" "cluster_autoscaler" {
    name = "cluster-autoscaler"
    chart = "https://x-access-token:${var.github_token}@github.com/cyse7125-su24-team10/helm-eks-autoscaler/archive/refs/tags/v${var.autoscaler_version}.tar.gz"
    namespace = "eks-autoscaler"
    wait = false 
    values = [
        "${file("./values/autoscaler-values.yaml")}"
    ]
    set { 
        name = "rbac.serviceAccount.name" 
        value = "cluster-autoscaler-service-account"
    }

    set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
    }
    set {
        name  = "autoDiscovery.clusterName"
        value = module.eks.cluster_name
    }

    set {
    name  = "awsRegion"
    value = var.provider_region
  }
   
   depends_on = [ module.eks, kubernetes_namespace.eks-autoscaler ]

}



// helm chart for fluent-bit that collects logs from the cluster and sends them to cloudwatch

resource "helm_release" "fluent-bit" {
    name      = "fluent-bit"
    chart = "./charts/fluent-bit"
    namespace = kubernetes_namespace.cloudwatch.metadata[0].name
    wait = false
  
}
