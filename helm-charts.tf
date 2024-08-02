
resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name       = "istio-base"
#   repository = "https://istio-release.storage.googleapis.com/charts"
  chart = "./charts/base"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  name       = "istiod"
#   repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "./charts/istiod"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  depends_on = [helm_release.istio_base]

  set {
    name  = "global.proxy.holdApplicationUntilProxyStarts"
    value = "true"
  }

  set {
    name  = "global.logAsJson"
    value = "true"
  }
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  chart      = "./charts/gateway"
  namespace  = kubernetes_namespace.istio_system.metadata[0].name
  depends_on = [helm_release.istiod]

  values = [
    <<-EOT
    service:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
        external-dns.alpha.kubernetes.io/hostname: "grafana.prod.skynetx.me"
      ports:
        - port: 80
          targetPort: 8080
          name: http2
        - port: 443
          targetPort: 8443
          name: https
        - port: 15021
          targetPort: 15021
          name: status-port
      type: LoadBalancer
    EOT
  ]
}

resource "kubernetes_namespace" "kafka" {
    metadata {
        name = "kafka"
        labels = {
            "istio-injection" = "enabled"
            "pod-security.kubernetes.io/enforce" = "privileged"
        }
    }
}

resource "kubernetes_namespace" "cve-consumer" {
    metadata {
        name = "cve-consumer"
        labels = {
            "istio-injection" = "enabled"
            "pod-security.kubernetes.io/enforce" = "privileged"
        }
    }
}

resource "kubernetes_namespace" "eks-autoscaler" {
    metadata {
        name = "eks-autoscaler"
        labels = {
            "istio-injection" = "enabled"
            "pod-security.kubernetes.io/enforce" = "privileged"
        }
    }
}

resource "kubernetes_namespace" "cve-operator" {
    metadata {
        name = "cve-operator"
        labels = {
            "istio-injection" = "enabled"
            "pod-security.kubernetes.io/enforce" = "privileged"
        }
    }
}

resource "kubernetes_namespace" "cloudwatch" {
    metadata {
        name = "amazon-cloudwatch"
    }
}

resource "kubernetes_namespace" "monitoring" {
    metadata {
        name = "monitoring"
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
    depends_on = [ module.eks, kubernetes_namespace.kafka, helm_release.prometheus_kafka_stack ]
}

resource "helm_release" "postgres_chart" {
    name      = "postgresql"
    chart = "./charts/bitnami-postgres"
    wait = false
    namespace = "cve-consumer"
    values = [
        "${file("./values/postgres-values.yaml")}"
    ]

    set {
        name  = "podAnnotations.sidecar\\.istio\\.io/inject"
        value = "false"
    }

    depends_on = [ module.eks, kubernetes_namespace.cve-consumer ]
}

resource "helm_release" "cluster_autoscaler" {
    name = "cluster-autoscaler"
    chart = "https://x-access-token:${var.github_token}@github.com/cyse7125-su24-team10/helm-eks-autoscaler/archive/refs/tags/v${var.autoscaler_version}.tar.gz"
    namespace = "eks-autoscaler"
    wait = true
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
    values = [ 
        "${file("./values/fluent-bit-values.yaml")}"
    ]
}


// helm chart for prometheus and grafana stack
resource "helm_release" "prometheus_grafana_stack" {
    name = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    wait = false
    values = [ 
        "${file("./values/prometheus-grafana-values.yaml")}"
    ]
}

// kafka exporter
resource "helm_release" "prometheus_kafka_stack" {
    name = "kafka-exporter"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "prometheus-kafka-exporter"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    wait = false
    values = [ 
        "${file("./values/prometheus-kafka-values.yaml")}"
    ]
}
