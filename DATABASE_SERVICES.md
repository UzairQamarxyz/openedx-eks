# External Database Services for OpenEdX

This document describes the external database services provisioned for the OpenEdX platform, following the architectural requirement that **all data services must be external to the Kubernetes cluster**.

## Architecture Overview

All database services are:

- ✅ **External to Kubernetes** - AWS managed services, not running in pods
- ✅ **Encrypted at Rest** - Using customer-managed KMS key (CMK)
- ✅ **Encrypted in Transit** - TLS/SSL enabled for all connections
- ✅ **Highly Available** - Multi-AZ deployments where applicable
- ✅ **Backed Up** - Automated backups with 7-day retention
- ✅ **Monitored** - CloudWatch logs and metrics enabled
- ✅ **Secure** - Private subnets, security groups, no public access

## Database Services

### 1. RDS MySQL - Application Data

**Purpose**: Relational database for OpenEdX application data

**Service**: Amazon RDS for MySQL
**Module**: `terraform-aws-modules/rds/aws`

**Configuration**:

- Engine: MySQL 8.0.35
- Instance Class: db.t3.medium (configurable)
- Storage: 100 GB GP3 (auto-scaling up to 200 GB)
- Multi-AZ: Enabled for high availability
- Backup: 7-day retention, automated backups
- Encryption: KMS CMK for storage, Performance Insights, and logs

**Features**:

- ✅ Storage encryption with CMK
- ✅ Performance Insights enabled
- ✅ Enhanced monitoring
- ✅ CloudWatch logs (error, general, slow query)
- ✅ Automatic minor version upgrades
- ✅ Multi-AZ deployment

**Connection**:

```bash
# Get endpoint
tofu output rds_mysql_endpoint

# Connection string format
mysql://username:password@endpoint:3306/openedx
```

### 2. DocumentDB - Course and User Data

**Purpose**: Document store for course content and user data (MongoDB-compatible)

**Service**: Amazon DocumentDB
**Module**: `terraform-aws-modules/documentdb/aws`

**Configuration**:

- Engine: DocumentDB 5.0.0 (MongoDB 4.0 compatible)
- Instance Class: db.t3.medium (configurable)
- Instances: 3 (1 primary + 2 replicas)
- Backup: 7-day retention, automated backups
- Encryption: KMS CMK for storage and logs

**Features**:

- ✅ Storage encryption with CMK
- ✅ Cluster with read replicas
- ✅ CloudWatch logs (audit, profiler)
- ✅ Automatic failover
- ✅ Point-in-time recovery

**Connection**:

```bash
# Get endpoint
tofu output documentdb_endpoint

# Connection string format (MongoDB compatible)
mongodb://username:password@endpoint:27017/?tls=true&tlsCAFile=rds-combined-ca-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false
```

**Note**: DocumentDB requires TLS. Download the CA bundle:

```bash
wget https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

### 3. OpenSearch - Search and Analytics

**Purpose**: Search engine and analytics platform for course search and analytics

**Service**: Amazon OpenSearch Service
**Resource**: Native AWS resource (no community module available)

**Configuration**:

- Engine: OpenSearch 2.11
- Instance Type: t3.medium.search (configurable)
- Instances: 3 data nodes + 3 dedicated master nodes
- Storage: 100 GB GP3 per node
- Encryption: KMS CMK for storage, node-to-node encryption
- Security: Fine-grained access control enabled

**Features**:

- ✅ Storage encryption with CMK
- ✅ Node-to-node encryption
- ✅ HTTPS enforcement (TLS 1.2+)
- ✅ Fine-grained access control
- ✅ CloudWatch logs (slow logs, application logs)
- ✅ OpenSearch Dashboards included
- ✅ Multi-AZ deployment

**Connection**:

```bash
# Get endpoint
tofu output opensearch_endpoint

# Dashboard endpoint
tofu output opensearch_dashboard_endpoint

# Connection format
https://username:password@endpoint:443
```

### 4. ElastiCache Redis - Cache and Message Broker

**Purpose**: In-memory cache and message broker for session management and task queues

**Service**: Amazon ElastiCache for Redis
**Resource**: Native AWS resource

**Configuration**:

- Engine: Redis 7.1
- Node Type: cache.t3.medium (configurable)
- Nodes: 3 (1 primary + 2 replicas)
- Encryption: KMS CMK for at-rest, TLS for in-transit
- Auth: AUTH token enabled

**Features**:

- ✅ At-rest encryption with CMK
- ✅ In-transit encryption (TLS)
- ✅ AUTH token authentication
- ✅ Automatic failover
- ✅ Multi-AZ deployment
- ✅ CloudWatch logs (slow log, engine log)
- ✅ Automated backups (7-day retention)

**Connection**:

```bash
# Get endpoint
tofu output redis_primary_endpoint

# Connection format (with AUTH)
redis://username:auth_token@endpoint:6379
```

## Network Architecture

### Security Groups

All databases share a common security group with the following rules:

```hcl
Ingress Rules (from EKS nodes only):
- MySQL:      Port 3306  (RDS MySQL)
- DocumentDB: Port 27017 (DocumentDB)
- Redis:      Port 6379  (ElastiCache)
- OpenSearch: Port 443   (HTTPS)

Egress: Allow all (for updates and patches)
```

### Subnet Configuration

All databases are deployed in **private subnets** across multiple availability zones:

- No public IP addresses
- No internet-facing endpoints
- Accessible only from within the VPC (EKS nodes)

## Encryption

### KMS Key Permissions

The CMK has been configured with permissions for all database services:

```hcl
Services with KMS access:
- RDS (MySQL and DocumentDB)
- ElastiCache (Redis)
- OpenSearch (es.amazonaws.com)
- CloudWatch Logs
```

### Encryption Coverage

| Service | At-Rest | In-Transit | Backups | Logs |
|---------|---------|------------|---------|------|
| RDS MySQL | ✅ CMK | ✅ TLS | ✅ CMK | ✅ CMK |
| DocumentDB | ✅ CMK | ✅ TLS | ✅ CMK | ✅ CMK |
| OpenSearch | ✅ CMK | ✅ TLS | ✅ CMK | ✅ CMK |
| Redis | ✅ CMK | ✅ TLS | ✅ CMK | ✅ CMK |

## High Availability

### Multi-AZ Deployments

| Service | Configuration | Failover |
|---------|---------------|----------|
| RDS MySQL | Multi-AZ (2 AZs) | Automatic |
| DocumentDB | 3 instances across 3 AZs | Automatic |
| OpenSearch | 3 data nodes + 3 masters across 3 AZs | Automatic |
| Redis | 3 nodes across 3 AZs | Automatic |

### Backup Strategy

All services have automated backups:

- **Retention**: 7 days
- **Backup Window**: 03:00-04:00 UTC
- **Maintenance Window**: Monday 04:00-05:00 UTC
- **Encryption**: All backups encrypted with CMK

## Monitoring and Logging

### CloudWatch Logs

Each service sends logs to CloudWatch:

**RDS MySQL**:

- Error logs
- General logs
- Slow query logs

**DocumentDB**:

- Audit logs
- Profiler logs

**OpenSearch**:

- Index slow logs
- Search slow logs
- Application logs

**Redis**:

- Slow logs
- Engine logs

All log groups are encrypted with the CMK.

### Metrics

Standard CloudWatch metrics are available for all services:

- CPU utilization
- Memory usage
- Disk I/O
- Network throughput
- Connection counts
- Query performance

## Cost Optimization

### Instance Sizing

Default configuration uses **t3.medium** instances for cost-effectiveness:

- Suitable for development and testing
- Burstable performance
- Can be scaled up for production

### Production Recommendations

For production workloads, consider:

**RDS MySQL**:

- Instance: db.r6g.xlarge or larger
- Storage: 500 GB+ with auto-scaling
- Read replicas for read-heavy workloads

**DocumentDB**:

- Instance: db.r6g.xlarge or larger
- Instances: 3-5 for better read distribution

**OpenSearch**:

- Instance: r6g.xlarge.search or larger
- Dedicated master nodes: 3x r6g.large.search
- Storage: 500 GB+ per node

**Redis**:

- Node: cache.r6g.xlarge or larger
- Nodes: 3-6 for better distribution

## Security Best Practices

### Credentials Management

**Current Setup** (Development):

```hcl
db_master_username = "admin"
db_master_password = "ChangeMe123!SecurePassword"
```

**Production Recommendations**:

1. **Use AWS Secrets Manager**:

```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "${local.name}-db-password"
  kms_key_id = module.kms.key_arn
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}
```

1. **Use IAM Authentication** (where supported):
   - RDS MySQL: IAM database authentication
   - DocumentDB: IAM authentication
   - OpenSearch: IAM-based access

2. **Rotate Credentials Regularly**:
   - Enable automatic rotation in Secrets Manager
   - Update application configurations

### Network Security

1. **VPC Endpoints**: Consider adding VPC endpoints for AWS services
2. **Network ACLs**: Add additional network ACL rules if needed
3. **Security Group Rules**: Review and tighten as needed

### Audit and Compliance

1. **Enable AWS Config**: Track configuration changes
2. **Enable CloudTrail**: Audit API calls
3. **Enable GuardDuty**: Threat detection
4. **Regular Security Scans**: Use AWS Inspector

## Connection from Kubernetes

### Using Kubernetes Secrets

Create secrets for database connections:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
type: Opaque
stringData:
  mysql-endpoint: "mysql-endpoint:3306"
  mysql-username: "admin"
  mysql-password: "password"
  documentdb-endpoint: "documentdb-endpoint:27017"
  documentdb-username: "admin"
  documentdb-password: "password"
  opensearch-endpoint: "https://opensearch-endpoint"
  opensearch-username: "admin"
  opensearch-password: "password"
  redis-endpoint: "redis-endpoint:6379"
  redis-password: "auth-token"
```

### Using External Secrets Operator

For better security, use External Secrets Operator with AWS Secrets Manager:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secrets
spec:
  provider:
    aws:
      service: SecretsManager
      region: eu-central-1
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets
    kind: SecretStore
  target:
    name: database-credentials
  data:
  - secretKey: mysql-password
    remoteRef:
      key: openedx/mysql/password
```

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to database from pods

**Solutions**:

1. Check security group rules allow EKS node security group
2. Verify pods are running in correct VPC
3. Check DNS resolution: `nslookup database-endpoint`
4. Verify credentials are correct

### Performance Issues

**Problem**: Slow database queries

**Solutions**:

1. Check CloudWatch metrics for resource utilization
2. Review slow query logs
3. Enable Performance Insights (RDS)
4. Consider scaling up instance size
5. Add read replicas for read-heavy workloads

### Encryption Issues

**Problem**: KMS key access denied

**Solutions**:

1. Verify KMS key policy includes database service
2. Check IAM permissions for database service role
3. Ensure key is in same region as database

## Maintenance

### Backup and Restore

**Create Manual Snapshot**:

```bash
# RDS MySQL
aws rds create-db-snapshot \
  --db-instance-identifier ex-auto-mode-community-mysql \
  --db-snapshot-identifier manual-snapshot-$(date +%Y%m%d)

# DocumentDB
aws docdb create-db-cluster-snapshot \
  --db-cluster-identifier ex-auto-mode-community-documentdb \
  --db-cluster-snapshot-identifier manual-snapshot-$(date +%Y%m%d)

# Redis
aws elasticache create-snapshot \
  --replication-group-id ex-auto-mode-community-redis \
  --snapshot-name manual-snapshot-$(date +%Y%m%d)
```

**Restore from Snapshot**:
Refer to AWS documentation for restore procedures.

### Scaling

**Vertical Scaling** (Change instance size):

```hcl
# Update terraform.auto.tfvars
rds_mysql_instance_class = "db.r6g.xlarge"

# Apply changes
tofu apply
```

**Horizontal Scaling** (Add replicas):

```hcl
# Update terraform.auto.tfvars
documentdb_instance_count = 5

# Apply changes
tofu apply
```

### Upgrades

**Engine Version Upgrades**:

```hcl
# Update terraform.auto.tfvars
rds_mysql_engine_version = "8.0.36"

# Apply changes (will cause downtime)
tofu apply
```

## Cost Estimation

Approximate monthly costs (eu-central-1, on-demand pricing):

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| RDS MySQL | db.t3.medium, 100GB, Multi-AZ | ~$120 |
| DocumentDB | 3x db.t3.medium | ~$450 |
| OpenSearch | 3x t3.medium.search, 300GB | ~$400 |
| Redis | 3x cache.t3.medium | ~$150 |
| **Total** | | **~$1,120/month** |

**Cost Optimization Tips**:

1. Use Reserved Instances for production (up to 60% savings)
2. Right-size instances based on actual usage
3. Use Savings Plans
4. Enable auto-scaling for storage
5. Delete unused snapshots
6. Use lifecycle policies for logs

## References

- [RDS MySQL Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html)
- [DocumentDB Documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/)
- [OpenSearch Documentation](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/)
- [ElastiCache Redis Documentation](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/)
- [OpenEdX Database Requirements](https://docs.openedx.org/)
