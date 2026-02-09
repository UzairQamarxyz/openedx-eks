<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| eks | terraform-aws-modules/eks/aws | 21.15.1 |
| eks\_env | cloudposse/label/null | 0.25.0 |
| openedx\_pod\_identity | terraform-aws-modules/eks-pod-identity/aws | 2.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.cloudwatch_observability](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.efs_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.pod_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.s3_csi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_security_group.control_plane_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster_egress_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.coredns_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| assets\_bucket\_arn | S3 bucket ARN for the 'assets' bucket used by pod identity policy. | `string` | n/a | yes |
| auto\_mode\_node\_pools | List of node pools for EKS Auto Mode (e.g., general-purpose, system). | `list(string)` | n/a | yes |
| aws\_efs\_csi\_driver\_add\_on\_version | Add-on version for aws-efs-csi-driver (null for latest). | `string` | n/a | yes |
| aws\_s3\_csi\_driver\_add\_on\_version | Add-on version for aws-s3-csi-driver (null for latest). | `string` | n/a | yes |
| cloudwatch\_log\_group\_retention\_days | Number of days to retain CloudWatch logs. | `number` | n/a | yes |
| cloudwatch\_observability\_add\_on\_version | Add-on version for CloudWatch observability (null for latest). | `string` | n/a | yes |
| cluster\_enabled\_log\_types | List of control plane logging types to enable. Valid values: api, audit, authenticator, controllerManager, scheduler. | `list(string)` | n/a | yes |
| cluster\_name | Logical EKS cluster name used for tagging and Karpenter discovery. | `string` | n/a | yes |
| create\_cloudwatch\_observability | Create CloudWatch observability add-on. | `bool` | n/a | yes |
| create\_efs\_csi\_driver | Create EFS CSI driver add-on. | `bool` | n/a | yes |
| create\_eks\_pod\_identity | Create EKS Pod Identity add-on. | `bool` | n/a | yes |
| create\_s3\_csi\_driver | Create S3 CSI driver add-on. | `bool` | n/a | yes |
| default\_kms\_key\_arn | Default KMS key ARN used for EKS encryption and CloudWatch logs. | `string` | n/a | yes |
| eks\_pod\_identity\_add\_on\_version | Add-on version for EKS Pod Identity (null for latest). | `string` | n/a | yes |
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod") - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| kubernetes\_version | Kubernetes version for the EKS cluster. | `string` | n/a | yes |
| private\_subnets | List of private subnet IDs for the EKS cluster. | `list(string)` | n/a | yes |
| public\_access\_cidrs | List of public subnet IDs for the EKS cluster. | `list(string)` | n/a | yes |
| vpc\_cidr | CIDR block of the VPC. | `string` | n/a | yes |
| vpc\_id | ID of the VPC where the EKS cluster will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_name | EKS cluster name |
| cluster\_primary\_security\_group\_id | Primary EKS cluster security group ID |
| node\_security\_group\_id | EKS node security group ID |
<!-- END_TF_DOCS -->