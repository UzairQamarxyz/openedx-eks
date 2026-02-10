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