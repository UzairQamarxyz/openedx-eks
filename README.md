# EKS Auto Mode - Community Modules

This example demonstrates how to create an EKS cluster with Auto Mode enabled using community modules (compatible with both OpenTofu and Terraform) instead of copebit's proprietary modules. The functionality is 1:1 with the copebit implementation.

## Features

This example provisions:

- **EKS Cluster** with Auto Mode enabled using `terraform-aws-modules/eks/aws`
- **VPC** with public and private subnets using `terraform-aws-modules/vpc/aws`
- **KMS Keys** with enhanced policies for EKS, S3, EBS, CloudWatch, and all database services
- **S3 Buckets** (consolidated module with random suffix) for logs, keys, and assets using `terraform-aws-modules/s3-bucket/aws`
- **SNS Topics** for alerts using `terraform-aws-modules/sns/aws`
- **EKS Add-ons**:
  - CloudWatch Observability
  - EKS Pod Identity Agent
  - EFS CSI Driver
  - S3 CSI Driver
- **External Database Services** (all encrypted with CMK, external to Kubernetes):
  - **RDS MySQL** - Relational database for OpenEdX application data
  - **DocumentDB** - MongoDB-compatible document store for course and user data
  - **OpenSearch** - Search and analytics engine
  - **ElastiCache Redis** - In-memory cache and message broker

## OpenTofu Compatibility

This example is fully compatible with both **OpenTofu** and **Terraform**:

- All modules work with OpenTofu >= 1.6.0
- Provider configurations are identical
- No OpenTofu-specific syntax required
- Simply use `tofu` command instead of `terraform`

## Key Differences from Copebit Modules

While maintaining 1:1 functionality, this example uses:

- `terraform-aws-modules/eks/aws` instead of `gitlab-external.copebit.ch/tofu-registry/eks/aws`
- `terraform-aws-modules/vpc/aws` instead of `gitlab-external.copebit.ch/tofu-registry/vpc/aws`
- `terraform-aws-modules/kms/aws` instead of `gitlab-external.copebit.ch/tofu-registry/kms/aws`
- `terraform-aws-modules/s3-bucket/aws` (consolidated with for_each) instead of `gitlab-external.copebit.ch/tofu-registry/s3/aws`
- `terraform-aws-modules/sns/aws` instead of `gitlab-external.copebit.ch/tofu-registry/sns/aws`
- `cloudposse/label/null` for standardized tagging
- Native AWS resources for EKS add-ons instead of copebit's addon module

## Enhanced Security Features

### KMS Key Policies

The KMS key includes comprehensive policies for:

- **Key Rotation**: Enabled for enhanced security
- **EKS Service Access**: Allows EKS to decrypt secrets and create grants
- **S3, EBS, CloudWatch Integration**: Service-specific access via ViaService condition
- **CloudWatch Logs Encryption**: Dedicated policy for log encryption

### EKS Auto Mode Node IAM Policies

The EKS Auto Mode nodes are configured with AWS-recommended policies:

- **AmazonEKSWorkerNodeMinimalPolicy**: Core permissions for EKS nodes
- **AmazonEC2ContainerRegistryPullOnly**: Pull container images from ECR
- **AmazonSSMManagedInstanceCore**: Optional SSM access for troubleshooting

### S3 Bucket Security

All S3 buckets are configured with:

- Public access blocked at all levels
- Versioning enabled
- KMS encryption with customer-managed keys
- Force destroy enabled for easy cleanup (disable in production)
- Random 8-character suffix for global uniqueness (no account ID exposure)

## Project Structure

The example follows infrastructure-as-code best practices with organized file structure:

- `main.tf` - Main infrastructure resources
- `data.tf` - Data sources
- `locals.tf` - Local values
- `variables.tf` - Input variable declarations (no defaults)
- `terraform.auto.tfvars` - Variable values and defaults
- `outputs.tf` - Output values
- `versions.tf` - Version constraints (OpenTofu/Terraform compatible)
- `deployment.yaml` - Sample Kubernetes deployment
- `README.md` - Documentation

## Auto Mode Configuration

EKS Auto Mode is enabled with the following configuration:

```hcl
cluster_compute_config = {
  enabled    = true
  node_pools = ["general-purpose"]
}
```

This allows EKS to automatically provision and manage compute resources based on workload requirements.

**Note:** EKS Auto Mode support was added in terraform-aws-modules/eks version 20.31.0. This example uses version ~> 20.36 (latest in v20.x series) which requires AWS Provider v5.x. For AWS Provider v6.x support, use EKS module v21.x or later.

## Configuration

All variable values are defined in `terraform.auto.tfvars`. You can customize:

- **S3 Buckets**: Modify `s3_bucket_names` to add/remove buckets
- **Node Pools**: Configure `auto_mode_node_pools` for different compute types
- **Logging**: Enable/disable control plane logs via `cluster_enabled_log_types`
- **Add-ons**: Toggle EKS add-ons and specify versions

## Usage

### With OpenTofu (Recommended)

To provision the cluster:

```bash
tofu init
tofu plan
tofu apply --auto-approve
```

Once the cluster is provisioned, configure kubectl and deploy a test workload:

```bash
aws eks update-kubeconfig --name $(tofu output -raw cluster_name) --region us-west-2
kubectl apply -f deployment.yaml
```

Watch as EKS Auto Mode automatically provisions nodes to run your workload:

```bash
kubectl get nodes -w
kubectl get pods -w
```

### With Terraform

Simply replace `tofu` with `terraform` in the commands above:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## Cleanup

To destroy all resources:

```bash
tofu destroy --auto-approve
# or
terraform destroy --auto-approve
```

## Requirements

| Name | Version |
|------|---------|
| OpenTofu/Terraform | >= 1.3.2 / >= 1.6.0 |
| aws | >= 5.70, < 6.0.0 |
| random | >= 3.6 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.70, < 6.0.0 |
| random | >= 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| tags | cloudposse/label/null | ~> 0.25 |
| eks | terraform-aws-modules/eks/aws | ~> 20.36 |
| vpc | terraform-aws-modules/vpc/aws | ~> 5.18 |
| kms | terraform-aws-modules/kms/aws | ~> 3.1 |
| s3_buckets | terraform-aws-modules/s3-bucket/aws | ~> 4.2 |
| sns_alerts | terraform-aws-modules/sns/aws | ~> 6.1 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| s3_bucket_names | List of S3 bucket names to create | `list(string)` | yes |
| auto_mode_node_pools | List of node pools for EKS Auto Mode | `list(string)` | yes |
| cluster_enabled_log_types | List of control plane logging types to enable | `list(string)` | yes |
| cloudwatch_log_group_retention_days | Number of days to retain CloudWatch logs | `number` | yes |
| create_cloudwatch_observability | Create cloudwatch observability add-on | `bool` | yes |
| create_eks_pod_identity | Create eks pod identity add-on | `bool` | yes |
| create_efs_csi_driver | Create efs-csi driver add-on | `bool` | yes |
| create_s3_csi_driver | Create s3-csi driver add-on | `bool` | yes |
| cloudwatch_observability_add_on_version | Add-on version for cloudwatch observability (null for latest) | `string` | yes |
| eks_pod_identity_add_on_version | Add-on version for eks pod identity (null for latest) | `string` | yes |
| aws_efs_csi_driver_add_on_version | Add-on version for aws-efs-csi-driver (null for latest) | `string` | yes |
| aws_s3_csi_driver_add_on_version | Add-on version for aws-s3-csi-driver (null for latest) | `string` | yes |

**Note**: All default values are defined in `terraform.auto.tfvars`

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | The Amazon Resource Name (ARN) of the cluster |
| cluster_endpoint | Endpoint for your Kubernetes API server |
| cluster_name | The name of the EKS cluster |
| cluster_version | The Kubernetes version for the cluster |
| vpc_id | VPC ID |
| s3_bucket_ids | Map of S3 bucket names to their IDs |
| s3_bucket_arns | Map of S3 bucket names to their ARNs |
| sns_alerts_topic_arn | ARN of the SNS alert topic |

## Notes

- This example uses AWS region `us-west-2` by default (configurable in locals.tf)
- The cluster is configured with Kubernetes version `1.33`
- NAT Gateway is configured in single mode to reduce costs
- All S3 buckets have `force_destroy = true` for easy cleanup (disable in production)
- VPC Flow Logs are enabled and sent to the S3 logs bucket
- Cluster logging is disabled by default to reduce costs during testing (configurable in terraform.auto.tfvars)
- Tags are standardized using the CloudPosse null label module
- EKS Auto Mode requires terraform-aws-modules/eks version >= 20.31.0
- **AWS Provider Compatibility**: This example uses EKS module v20.36 which requires AWS Provider v5.x (>= 5.70, < 6.0.0)
  - For AWS Provider v6.x, upgrade to EKS module v21.x or later
- KMS key rotation is enabled for enhanced security
- Node IAM policies follow AWS best practices for EKS Auto Mode
- **OpenTofu Compatible**: Works with both OpenTofu >= 1.6.0 and Terraform >= 1.3.2

## Policy Verification

### KMS Policies

The KMS key includes:

- ✅ Key rotation enabled
- ✅ EKS service access for secrets encryption
- ✅ S3, EBS, CloudWatch service integration
- ✅ Autoscaling service role access
- ✅ CloudWatch Logs encryption support

### S3 Bucket Policies

All S3 buckets include:

- ✅ Public access blocked
- ✅ Versioning enabled
- ✅ KMS encryption with customer-managed keys
- ✅ Secure by default configuration

### EKS Node Policies

EKS Auto Mode nodes include:

- ✅ AmazonEKSWorkerNodeMinimalPolicy (required)
- ✅ AmazonEC2ContainerRegistryPullOnly (required)
- ✅ AmazonSSMManagedInstanceCore (optional, for troubleshooting)

These policies match AWS documentation requirements for EKS Auto Mode.
