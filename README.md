# infra-aws

Production-Grade Kubernetes Cluster set-up on AWS with Terraform and Helm, including Istio for service mesh, Kafka for messaging, and KMS keys for encryption. Configured for high availability, scalability, and secure management of resources.

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5.svg?style=for-the-badge&logo=Kubernetes&logoColor=white)
[![Terraform](https://img.shields.io/badge/Terraform-844FBA.svg?style=for-the-badge&logo=Terraform&logoColor=white)](https://www.terraform.io/)
[![Amazon Web Services](https://img.shields.io/badge/Amazon%20Web%20Services-232F3E.svg?style=for-the-badge&logo=Amazon-Web-Services&logoColor=white)](https://aws.amazon.com/)
![Amazon Route 53](https://img.shields.io/badge/Amazon%20Route%2053-8C4FFF.svg?style=for-the-badge&logo=Amazon-Route-53&logoColor=white)
![Amazon CloudWatch](https://img.shields.io/badge/Amazon%20CloudWatch-FF4F8B.svg?style=for-the-badge&logo=Amazon-CloudWatch&logoColor=white)
[![EKS](https://img.shields.io/badge/EKS-FF9900.svg?style=for-the-badge&logo=Amazon-EKS&logoColor=white)](https://aws.amazon.com/eks/)
![Helm](https://img.shields.io/badge/Helm-0F1689.svg?style=for-the-badge&logo=Helm&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800.svg?style=for-the-badge&logo=Grafana&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20.svg?style=for-the-badge&logo=Apache-Kafka&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C.svg?style=for-the-badge&logo=Prometheus&logoColor=white)
![Fluent Bit](https://img.shields.io/badge/Fluent%20Bit-49BDA5.svg?style=for-the-badge&logo=Fluent-Bit&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0.svg?style=for-the-badge&logo=Istio&logoColor=white)



## Project Overview

This project sets up a robust infrastructure on AWS using Terraform, Helm, and Kubernetes, primarily focused on deploying and managing services in an EKS (Elastic Kubernetes Service) cluster. It includes various components and configurations to support a production-grade environment.

### Key Components

- **EKS Cluster**: The project provisions an EKS cluster using Terraform, which serves as the foundation for deploying Kubernetes workloads.

- **Namespaces**: Several Kubernetes namespaces are created for organizational purposes, including:
  - `istio-system`: For Istio service mesh components.
  - `cert-manager`: For managing TLS certificates.
  - `cve-processor`, `kafka`, `cve-consumer`, `eks-autoscaler`, `cve-operator`, `llm-cve`: For specific applications and services.
  - `amazon-cloudwatch`, `monitoring`, `metrics-server`: For monitoring and logging.

- **KMS Keys**:
  - **EKS Secrets Key**: Manages encryption for EKS secrets with key rotation enabled.
  - **EBS Key**: Manages encryption for EBS volumes with specific IAM permissions and key rotation.

- **Security Groups**:
  - **`eks_node_group_allow_istio_sg`**: Allows incoming TCP traffic on port 15017 from any IP address to facilitate communication for Istio components.

### Additional Features

This infrastructure setup provides a comprehensive solution for deploying, managing, and scaling applications in a Kubernetes environment on AWS, integrating with monitoring, logging, and security services.


## Helm Charts Bootstrapped During Terraform Apply

1. **Istio Base and Istiod:**
   - Istio is deployed to manage service mesh capabilities for the cluster, enabling secure and observable communication between microservices.
   - The Istio base chart installs Custom Resource Definitions (CRDs) required for Istio's operation.
   - Istiod serves as the control plane, responsible for traffic routing, service discovery, and security, with features like mutual TLS and logging.

2. **Istio Ingress Gateway:**
   - The Istio Ingress Gateway provides entry point management for external traffic into the cluster, enabling secure and controlled access to services.
   - Custom configurations include proxy settings for enhanced control and reliability in managing incoming traffic.

3. **Cert-Manager:**
   - Cert-Manager, when enabled, automates the issuance and renewal of TLS certificates within the Kubernetes cluster.
   - It supports certificate management for workloads to ensure secure communication.

4. **Kafka:**
   - Kafka is deployed to handle event streaming, providing a highly scalable platform for processing real-time data within the cluster.
   - Includes SASL authentication and SSL/TLS encryption for secure communication between Kafka brokers, producers, and consumers.
   - Kafka is integrated with Prometheus to monitor its health and performance.

5. **Prometheus and Grafana Stack:**
   - Prometheus is used for monitoring cluster resources, collecting metrics from Kubernetes components, and providing alerts.
   - Grafana is integrated for visualization, offering pre-configured dashboards for real-time insights into cluster health and workloads.
   - Kafka metrics are exported via the Prometheus Kafka Exporter, enabling detailed monitoring of Kafka pods.

6. **Fluent-Bit for CloudWatch:**
   - Fluent-Bit is deployed to gather logs from the cluster and send them to Amazon CloudWatch for centralized log management.
   - Helps monitor application logs and system events for enhanced observability and troubleshooting.

7. **Cluster Autoscaler:**
   - Automatically adjusts the number of nodes in the EKS cluster based on resource demand.
   - Ensures optimal resource allocation by adding or removing nodes as workloads fluctuate.
   - Integrated with IAM roles and service accounts for secure scaling operations.

8. **Metrics Server:**
   - Metrics Server collects resource usage data from Kubernetes nodes and pods, providing the necessary metrics for autoscaling.
   - This enables Kubernetes Horizontal Pod Autoscaler (HPA) to scale pods based on real-time CPU and memory usage.

## Helm Charts Configuration

1. Cluster-autoscaler

```bash
awsRegion: us-east-1
image:
  repository: "vkneu7/eks-autoscaler"
  tag: v1.30.0-amd64
  pullPolicy: IfNotPresent
  pullSecrets: 
    - name: docker-hub-pat
rbac:
  create: true
  pspEnabled: false
  clusterScoped: true
  serviceAccount:
    annotations: {}
    create: true
    name: "cluster-autoscaler-service-account"
    automountServiceAccountToken: true
secrets: 
  dbPassword: "placeholder_for_db_password"
  dockerConfigJson: "placeholder_for_docker_config_json"
  kafkaPassword: "placeholder_for_kafka_password"
```
2. Fluetbit 
```bash
clusterName: csye7125
regionName: us-east-1
fluentBitHttpPort: "2020"
fluentBitHttpServer: "On"
fluentBitReadFromHead: "Off"
fluentBitReadFromTail: "On"
```

3. Kafka
```bash
sasl:
  enabledMechanisms: PLAIN,SCRAM-SHA-256,SCRAM-SHA-512
  client:
    users:
      - user1
    passwords: "*****"
controller:
  resourcesPreset: "medium"
provisioning:
  enabled: true
  numPartitions: 1
  replicationFactor: 1
  topics:
    - name: cve
      partitions: 3
      replicationFactor: 3
      config:
        max.message.bytes: 64000
        flush.messages: 1
  postScript: |
    trap "curl --max-time 2 -s -f -XPOST http://127.0.0.1:15020/quitquitquit" EXIT; 
    while ! curl -s -f http://127.0.0.1:15020/healthz/ready; do 
    sleep 1; 
    done; 
    echo "Ready!"
```
4. Postgresql
```bash
global:
  postgresql:
    auth:
      postgresPassword: "git"
      username: "web_app"
      password: "*******"
      database: "cve"
    service:
      ports:
        postgresql: "5432"
primary:
  resourcesPreset: "small"
  labels: 
    app: cve-db
  podLabels:
    app: cve-db
metrics:
  ## @param metrics.enabled Start a prometheus exporter
  ##
  enabled: true
```

5. Prometheus-grafana 
```bash
grafana:
  adminPassword: ****** for grafana dashboard
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
    - job_name: "postgres-metrics"
      static_configs:
      - targets:
        - "postgresql-metrics.cve-consumer.svc.cluster.local:9187"
    - job_name: "kafka-jmx-metrics"
      static_configs:
      - targets:
        - "kafka-jmx-metrics.kafka.svc.cluster.local:5556"  

```

6. kafka-exporter
```bash
kafkaServer:
  - kafka.kafka.svc.cluster.local:9092
prometheus:
  serviceMonitor:
    enabled: true
    namespace: monitoring
    apiVersion: "monitoring.coreos.com/v1"
    interval: "30s"
    additionalLabels:
      release: prometheus
    targetLabels: []
sasl:
  enabled: true
  handshake: true
  scram:
    enabled: true
    mechanism: scram-sha256

    # add username and password
    username: user1
    password: ****
```

## Prerequisites
Ensure the following tools are installed and configured before proceeding:
- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- AWS credentials configured for the target environment.

## Setup Instructions

 1. **Clone the Repository**
```bash
git clone git@github.com:your-username/infra-aws.git
cd infra-aws
```
 2. **Add terraform.tfvars file: Example below**
    ```hcl
    provider_region = "us-east-1"
    #vpc
    eks_vpc_cidr_block = "10.0.0.0/16"
    eks_vpc_tag_name = "eks-vpc"
    #public subnet1
    eks_public_subnet1_availability_zone = "us-east-1a"
    eks_public_subnet1_cidr_block = "10.0.1.0/24"
    eks_public_subnet_tag = "eks-public-subnet"
    #public subnet2
    eks_public_subnet2_availability_zone = "us-east-1b"
    eks_public_subnet2_cidr_block = "10.0.2.0/24"
    #public subnet3
    eks_public_subnet3_availability_zone = "us-east-1c"
    eks_public_subnet3_cidr_block = "10.0.3.0/24" 
    #private subnet1
    eks_private_subnet1_availability_zone = "us-east-1a"
    eks_private_subnet1_cidr_block = "10.0.4.0/24" 
    eks_private_subnet_tag = "eks-private-subnet"
    #private subnet2
    eks_private_subnet2_availability_zone = "us-east-1b"
    eks_private_subnet2_cidr_block = "10.0.5.0/24" 
    #private subnet3
    eks_private_subnet3_availability_zone = "us-east-1c"
    eks_private_subnet3_cidr_block = "10.0.6.0/24"
    #Route Table
    route_table_cidr_block = "0.0.0.0/0"
    #EKS Module
    eks_cluster_name = "csye7125"
    eks_cluster_version = "1.29"
    eks_cluster_authentication_mode = "API_AND_CONFIG_MAP"
    #EKS managed node group
    ami_type = "AL2_x86_64"
    min_size = 3
    max_size = 7
    desired_size = 4
    instance_types = [ "c3.large" ]
    capacity_type = "ON_DEMAND"
    max_unavailable = 1
    #Block device mappings 
    device_name = "/dev/xvda"
    ebs_volume_size = 20
    ebs_volume_type = "gp2"
    #tags
    environment_tag = "dev"
    #Cluster encryption config resources
    cluster_encryption_config_resources = ["secrets"]
    cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    #KMS KEYS
    eks_secrets_key_description = "KMS key for EKS secrets encryption"
    deletion_window_in_days = 7
    ebs_key_description = "KMS key for EBS encryption"
    ebs_key_usage = "ENCRYPT_DECRYPT"
    customer_master_key_spec = "SYMMETRIC_DEFAULT"
    github_token = "your_github_api_key"
    autoscaler_version = "1.0.0"
    #Ingress values 
    istio_ingress_values = <<-EOT
    service:
    annotations:
        service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
        service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
        external-dns.alpha.kubernetes.io/hostname: "grafana.prod.skynetx.me,cve.prod.skynetx.me"
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
    #EKS Blueprint addon
    cert_manager_route53_hosted_zone_arns = ["arn:aws:route53:::hostedzone/your_hosted_zone_id"]
    route53_hosted_zone =  "prod.skynetx.me"

 3. **Setup aws profile on cli**
    ```bash
    export AWS_PROFILE=dev
    ```

 4. **Initialize Terraform:**
    ```bash
    terraform init
    ```

 5. **Terraform Configuration:**
   Review the `terraform.tfvars`. Modify variables in `terraform.tfvars` as needed for your environment.

 6. **Plan Infrastructure Changes:**
    ```bash
    terraform plan
    ```

7. **Apply Infrastructure Changes:**
    ```bash
    terraform apply
    ```

 8. **Verify the Infrastructure:**
   After Terraform applies the changes successfully, verify the infrastructure on AWS.

## Cleaning Up
Instructions for tearing down the infrastructure

1. **Destroy Infrastructure:**
    ```bash
    terraform destroy
    ```

2. **Confirm Destruction:**
   Terraform will prompt you to confirm destruction. Enter `yes` to proceed with tearing down the infrastructure.
