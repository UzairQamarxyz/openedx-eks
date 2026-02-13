# Open edX Production-Ready Infrastructure (AWS EKS)

This repository contains the **Terraform** infrastructure-as-code (IaC) required to deploy a
production-ready Open edX platform on AWS. The architecture is designed to meet strict enforcement
criteria for scalability, reliability, and operational discipline.

## Architectural Decisions

### Flux CD for GitOps

This project utilizes Flux CD for a fully automated GitOps workflow, ensuring that the state of the
Kubernetes cluster mirrors the configuration defined in this repository. This approach provides
reproducibility and a single source of truth for the entire application deployment.

### Initial Approach: Manifest-Based GitOps

Originally, the plan was to adopt an "all flux only" approach. This involved the following steps:
1.  Rendering Kubernetes manifests locally using `tutor`.
2.  Storing the generated manifests directly in the Git repository.
3.  Using Flux CD to apply these manifests to the cluster.

This method offered two primary advantages:
- **Greater Customizability:** Direct manipulation of manifests allows for fine-grained control over every aspect of the deployment.
- **Enhanced Security:** Secrets could be encrypted in the Git repository using [SOPS](https://github.com/mozilla/sops), providing an extra layer of security for sensitive data.

However, this approach was abandoned due to unforeseen issues during implementation. The current
strategy simplifies the deployment process while still leveraging the power of GitOps with Flux CD.

## Architectural Judgment & Design

This deployment follows a **Kubernetes-native** pattern, explicitly avoiding VM-style configurations
to ensure full compatibility with modern cloud-native orchestration.

### Core Infrastructure Components

- **Compute:** Amazon EKS configured with **EKS Auto Mode** for seamless horizontal and vertical
  scaling of both pods and nodes.
- **Traffic Management:** Governed exclusively through an **Nginx Ingress Controller**. This ensures
  clear separation between traffic management and application services, with no direct exposure via
  NodePort or LoadBalancer.
- **Data Services (Externalized):** To meet production-ready standards, all stateful services are
  hosted **external to the cluster** using managed AWS services:
  - **Aurora MySQL:** Core relational data.
  - **DocumentDB (MongoDB API):** Course content and persistence.
  - **Amazon ElastiCache (Redis):** Caching and task queues.
  - **Amazon OpenSearch:** Platform and course search functionality.
- **Certificate Management:** **cert-manager** is deployed to automatically provision and manage TLS
  certificates, enabling HTTPS for all public-facing services. It handles the entire lifecycle of
  certificate creation and renewal against the specified domains.

### GitOps & Scaling

- **Flux CD:** Deployed for continuous, automated GitOps integration, ensuring the live environment
  stays synchronized with the repository state.
- **Hyperscale Readiness:** Application pods are stateless and governed by **Horizontal Pod
  Autoscalers (HPA)**.
- **Backup & Recovery:** **AWS Backup** is used to protect persistent volumes (EBS), RDS databases,
  and the EKS cluster itself. Backups are managed efficiently through resource tagging, allowing
  for centralized and automated data protection policies.

## Repository Structure

```text
.
├── main.tf                # Main entry point for AWS resource orchestration
├── modules/               # Modularized infrastructure components
│   ├── eks/               # EKS Cluster with Auto Mode and HPA enabled
│   ├── ingress-nginx/     # Nginx Ingress Controller configuration
│   ├── rds/               # Aurora MySQL (External Database)
│   ├── documentdb/        # External MongoDB for course persistence
│   ├── redis/             # External ElastiCache for caching
│   ├── opensearch/        # External Search service
│   ├── backup/            # AWS Backup vault and plan configurations
│   ├── flux/              # Flux CD GitOps bootstrap
│   └── vpc/               # Network isolation and VPC subnets
├── accountprep.tf         # Initial AWS account baseline
└── networkprep.tf         # Global networking and VPC Peering/Transit settings
```

## Enforcement & Compliance

As per the **Enforcement Criteria**, this submission demonstrates:

1. **Production-Ready Definition:**
   - The deployment is Kubernetes-native, with a clear separation between traffic management, application services, and data services.
   - It has no dependency on single-pod or in-cluster state for critical data.
   - The architecture is designed for horizontal scaling and failure recovery.
2. **Ingress Requirement:**
   - An Nginx Ingress Controller is deployed to manage all external access.
   - OpenEdX LMS and CMS are exposed exclusively through the ingress.
   - The default Tutor Caddy server is not used, and there is no direct exposure via NodePort or LoadBalancer.
3. **External Database Requirement:**
   - All stateful services are external to the Kubernetes cluster, using AWS managed services (RDS, DocumentDB, ElastiCache, OpenSearch).
4. **Data Persistence Validation:**
   - Course creation and modifications in OpenEdX Studio are persisted in an external DocumentDB instance.
   - All data is retained after pod restarts or rescheduling.
5. **Hyperscale Readiness:**
   - LMS and CMS application pods are stateless.
   - Readiness and liveness probes are properly configured.
   - A Horizontal Pod Autoscaler (HPA) is configured for automatic scaling based on resource utilization.

## Live Environment Walkthrough

Reviewers can validate the production-readiness by:

- Inspecting **DocumentDB** collections to verify course persistence after LMS/CMS pod restarts.
- Observing **HPA behavior** during load testing to confirm hyperscale readiness.
- Verifying that all LMS/CMS traffic is governed by the **Nginx Ingress Controller**.

## Setup Guide

1. Edit the `terraform.auto.tfvars` according to your setup.
   1.1. Make sure to update the `dns_hosted_zone_name` with yours.
   1.2. Make sure to update the `git_repo_url` with yours.
   1.3. Make sure to update the `git_branch` with yours.

2. Do a tofu/terraform init and apply.
   2.1. Do a tofu/terraform apply without flux.
       ```sh
       terraform apply -exclude="module.flux.helm_release.flux_operator"
       ```
   2.2. Now do a complete apply.
       ```sh
       terraform apply
       ```

3. Now run the command in the output.

   ```sh
   # ⚠️ This command automatically executes tutor save config according to the infra deployed
   terraform output  -raw tutor_config_all | bash
   ```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.2 |
| aws | ~> 6.0 |
| random | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| aws | 6.31.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| buckets | ./modules/s3 | n/a |
| documentdb | ./modules/documentdb | n/a |
| eks\_cluster | ./modules/eks | n/a |
| kms | ./modules/kms | n/a |
| opensearch | ./modules/opensearch | n/a |
| rds\_mysql | ./modules/rds | n/a |
| redis | ./modules/redis | n/a |
| sns\_alerts | ./modules/sns | n/a |
| vpc | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| auto\_mode\_node\_pools | List of node pools for EKS Auto Mode (e.g., general-purpose, system) | `list(string)` | n/a | yes |
| aws\_efs\_csi\_driver\_add\_on\_version | Provide the add\_on version for aws-efs-csi-driver (null for latest) | `string` | n/a | yes |
| aws\_region | AWS region to deploy resources in | `string` | n/a | yes |
| aws\_s3\_csi\_driver\_add\_on\_version | Provide the add\_on version for aws-s3-csi-driver (null for latest) | `string` | n/a | yes |
| bucket\_duties | List of S3 bucket names to create (e.g., logs, keys, assets) | `list(string)` | n/a | yes |
| cloudwatch\_log\_group\_retention\_days | Number of days to retain CloudWatch logs | `number` | n/a | yes |
| cloudwatch\_observability\_add\_on\_version | Provide the add\_on version for cloudwatch observability (null for latest) | `string` | n/a | yes |
| cluster\_enabled\_log\_types | List of control plane logging types to enable. Valid values: api, audit, authenticator, controllerManager, scheduler | `list(string)` | n/a | yes |
| create\_aoss\_key | Whether to create a KMS key for OpenSearch Service encryption | `bool` | n/a | yes |
| create\_cloudwatch\_observability | Create cloudwatch observability add-on | `bool` | n/a | yes |
| create\_default\_key | Whether to create a default KMS key for general use | `bool` | n/a | yes |
| create\_ebs\_key | Whether to create a KMS key for EBS encryption | `bool` | n/a | yes |
| create\_efs\_csi\_driver | Create efs-csi driver add-on | `bool` | n/a | yes |
| create\_efs\_key | Whether to create a KMS key for EFS encryption | `bool` | n/a | yes |
| create\_eks\_pod\_identity | Create eks pod identity add-on | `bool` | n/a | yes |
| create\_elasticache\_key | Whether to create a KMS key for ElastiCache encryption | `bool` | n/a | yes |
| create\_firewall\_key | Whether to create a KMS key for Firewall encryption | `bool` | n/a | yes |
| create\_rds\_key | Whether to create a KMS key for RDS encryption | `bool` | n/a | yes |
| create\_s3\_csi\_driver | Create s3-csi driver add-on | `bool` | n/a | yes |
| create\_s3\_key | Whether to create a KMS key for S3 encryption | `bool` | n/a | yes |
| db\_master\_password | Master password for databases | `string` | n/a | yes |
| db\_master\_username | Master username for databases | `string` | n/a | yes |
| dns\_hosted\_zone\_name | DNS hosted zone name for Route53 (e.g., example.com) | `string` | n/a | yes |
| documentdb\_engine\_version | DocumentDB engine version | `string` | n/a | yes |
| documentdb\_instance\_class | Instance class for DocumentDB | `string` | n/a | yes |
| documentdb\_instance\_count | Number of DocumentDB instances | `number` | n/a | yes |
| eks\_pod\_identity\_add\_on\_version | Provide the add on version for eks pod identity (null for latest) | `string` | n/a | yes |
| env\_vars | Environment variables for the module | `map(string)` | n/a | yes |
| kubernetes\_version | Kubernetes version for the EKS cluster | `string` | n/a | yes |
| opensearch\_ebs\_volume\_size | EBS volume size for OpenSearch in GB | `number` | n/a | yes |
| opensearch\_engine\_version | OpenSearch engine version | `string` | n/a | yes |
| opensearch\_instance\_count | Number of OpenSearch instances | `number` | n/a | yes |
| opensearch\_instance\_type | Instance type for OpenSearch | `string` | n/a | yes |
| public\_access\_cidrs | List of CIDR blocks for public access (e.g., office IPs) | `list(string)` | n/a | yes |
| rds\_mysql\_allocated\_storage | Allocated storage for RDS MySQL in GB | `number` | n/a | yes |
| rds\_mysql\_engine\_version | MySQL engine version | `string` | n/a | yes |
| rds\_mysql\_instance\_class | Instance class for RDS MySQL | `string` | n/a | yes |
| redis\_cluster\_size | Number of nodes for Redis | `number` | n/a | yes |
| redis\_engine\_version | Redis engine version | `string` | n/a | yes |
| redis\_instance\_type | Instance class for ElastiCache Redis | `string` | n/a | yes |
| subscriber\_email\_addresses | Subscription emails for events & alerts. | `map(list(string))` | n/a | yes |
| vpc\_cidr | CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| documentdb\_username | DocumentDB master username |
| rds\_mysql\_endpoint | RDS MySQL endpoint |
| rds\_mysql\_master\_secret\_arn | RDS MySQL master secret ARN |
| rds\_mysql\_port | RDS MySQL port |
| rds\_mysql\_username | RDS MySQL master username |
| redis\_primary\_endpoint\_address | ElastiCache Redis primary endpoint address |
| redis\_primary\_endpoint\_port | ElastiCache Redis primary endpoint port |
<!-- END_TF_DOCS -->