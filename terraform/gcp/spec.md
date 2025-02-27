# Bindplane GCP Terraform Deployment Specification

## Overview

This Terraform configuration provides infrastructure for deploying Bindplane on Google Cloud Platform (GCP).
It sets up a production-ready environment with a GKE cluster, Cloud SQL PostgreSQL database,
and all necessary networking components.

## Components

### 1. GKE Cluster

- Kubernetes cluster for running Bindplane services:

  - Bindplane server
  - Transform agent
  - Prometheus

- Recommended specifications:

  1. Kubernetes Version:

     - Version 1.27 or newer
     - Provides Gateway API support
     - Extended support window
     - Enhanced security features
     - Latest Prometheus operator compatibility

  2. Node Pool Configuration:

     - Machine type: e2-standard-4 (4 vCPU, 16GB RAM)
     - Initial size: 3 nodes
     - Autoscaling range: 3-5 nodes
     - OS: Container-Optimized OS
     - Rationale: Matches resource requirements, provides redundancy and scaling capacity

  3. Cluster Architecture:

     - Type: Regional (3 zones)
     - Example regions: us-central1-a, us-central1-b, us-central1-c
     - Rationale: High availability, disaster recovery, zone failure protection

  4. Network Configuration:

     - Private cluster with Cloud NAT
     - Private control plane endpoint
     - Authorized networks for access
     - Rationale: Enhanced security, controlled egress, protected control plane

  5. Additional Features:
     - Workload Identity: Enabled (for secure service authentication)
     - Container-native load balancing: Enabled
     - Network Policy: Enabled
     - Binary Authorization: Enabled
     - Backup for GKE: Enabled
     - GKE usage metering: Enabled

- Requirements to be determined:
  - Specific authorized networks
  - Custom node labels/taints
  - Resource quotas
  - Maintenance window preferences

### 2. Cloud SQL PostgreSQL

- Managed PostgreSQL instance for Bindplane data

- Current specifications (from docker-compose):

  - PostgreSQL version: 16
  - Database name: bindplane
  - User: bindplane

- Recommended specifications:

  1. Instance Configuration:

     - Tier: db-custom-2-8192 (2 vCPU, 8GB RAM)
     - Storage: 100GB SSD (autoscaling enabled)
     - High availability: Enabled with failover replica
     - Region: Same as GKE cluster for minimal latency
     - Rationale: Balanced performance and cost for typical deployments

  2. Backup Configuration:

     - Automated backups: Enabled
     - Backup window: 4-hour window during off-peak
     - Backup retention: 7 days
     - Point-in-time recovery: Enabled
     - Rationale: Ensures data safety with minimal impact

  3. Network Configuration:

     - Private IP only
     - No public IP
     - VPC peering with GKE network
     - Cloud SQL Auth Proxy optional but recommended
     - Rationale: Enhanced security, reliable connectivity

  4. Database Settings:

     - Character set: UTF8
     - SSL connections: Required
     - Automated maintenance: Enabled
     - Query insights: Enabled
     - Rationale: Production-ready configuration

  5. Performance Optimization:
     - Shared buffer: 2GB
     - Temp buffer: 32MB
     - Work memory: 16MB
     - Maintenance window: Coordinated with GKE maintenance
     - Rationale: Optimized for Bindplane workload

- Requirements to be determined:
  - Specific maintenance window
  - Exact storage growth projections
  - Backup retention requirements beyond 7 days
  - Database user roles and permissions

### 3. Networking

- VPC network configuration

- Recommended specifications:

  1. VPC Design:

     - Dedicated VPC for Bindplane environment
     - Regional subnets aligned with GKE/Cloud SQL regions
     - Secondary IP ranges for GKE pods and services
     - Cloud NAT for outbound internet access
     - Rationale: Isolated, scalable network architecture

  2. IP Range Allocation:

     - Primary subnet: /20 (4,096 IPs)
     - GKE pods: /16 (65,536 IPs)
     - GKE services: /20 (4,096 IPs)
     - Cloud SQL private services: /24 (256 IPs)
     - Rationale: Room for growth, standard sizing

  3. Load Balancing:

     - Internal load balancer for database access
     - External HTTP(S) load balancer for UI/API
     - SSL termination at load balancer
     - Rationale: Secure, scalable access

  4. Firewall Configuration:

     - Default deny all
     - Explicit allow rules for:
       - GKE master to nodes
       - Health checks
       - Internal service communication
       - Load balancer to services
     - Rationale: Principle of least privilege

  5. Private Service Access:
     - Enabled for Cloud SQL
     - Private Google Access enabled
     - Service Directory integration
     - Rationale: Secure service connectivity

- Requirements to be determined:
  - Specific IP ranges based on existing infrastructure
  - Custom firewall rules for specific needs
  - VPC peering requirements
  - Cloud Armor security policies

### 4. Security

- Secret Manager for sensitive data

- Recommended specifications:

  1. Secret Management:

     - Cloud Secret Manager for all secrets:
       - Bindplane license
       - Database credentials
       - Session secrets
       - API keys
       - SSL certificates
     - Automatic rotation enabled where supported
     - Rationale: Centralized, secure secret management

  2. IAM Configuration:

     - Custom service accounts for:
       - GKE nodes
       - Cloud SQL
       - Workload Identity
     - Least privilege access
     - Regular audit logging
     - Rationale: Granular access control

  3. Network Security:

     - VPC Service Controls enabled
     - Private Google Access
     - Cloud Armor for WAF/DDoS protection
     - Regular security scanning
     - Rationale: Defense in depth

  4. Encryption:

     - Customer-managed encryption keys (CMEK)
     - TLS 1.3 for all external traffic
     - At-rest encryption for all data
     - Rationale: Data protection at all layers

  5. Compliance & Monitoring:
     - Security Command Center integration
     - Regular compliance scanning
     - Audit logging enabled
     - Cloud Monitoring alerts
     - Rationale: Proactive security stance

- Requirements to be determined:
  - Specific compliance requirements
  - Custom security policies
  - Key rotation schedules
  - Access review procedures

## Environment Variables

Based on docker-compose configuration:

```bash
BINDPLANE_LICENSE              # Bindplane license key
BINDPLANE_SESSIONS_SECRET     # Random UUID for session encryption
BINDPLANE_SECRET_KEY         # Random UUID for API key encryption
```

## Service Configuration

### Bindplane Server

- Image: ghcr.io/observiq/bindplane-ee:1.87.0
- Environment variables needed:
  - Database connection
  - License
  - Session secrets
  - Prometheus configuration
  - Transform agent configuration

### Transform Agent

- Image: ghcr.io/observiq/bindplane-transform-agent:1.87.0-bindplane
- Health check requirements:
  - Port: 4568
  - Path: /health

### Prometheus

- Image: ghcr.io/observiq/bindplane-prometheus:1.87.0
- Persistent storage requirements
- Health check endpoint: /-/healthy

## Questions to Resolve

### GKE Configuration

1. Minimum Kubernetes version required
2. Node pool size requirements
3. Multi-zone or regional cluster preference
4. Public or private cluster requirement
5. Workload identity configuration needs

### Database Requirements

1. High availability needs
2. Backup retention period
3. Instance size (CPU/RAM)
4. Storage size and growth projections
5. Maintenance window preferences

### Networking Requirements

1. Existing VPC requirements
2. IP range allocations
3. External access patterns
4. Load balancer preferences
5. Internal vs external database access

### Security Requirements

1. IAM role definitions
2. Network policy specifications
3. Encryption requirements
4. Compliance standards to meet
5. Access control needs

### Monitoring Requirements

1. Cloud Monitoring integration needs
2. Log retention requirements
3. Metrics collection requirements
4. Alert configuration needs

### Scaling Requirements

1. Expected load/user count
2. Auto-scaling parameters
3. Resource quotas
4. Backup and DR requirements

## Implementation Phases

1. **Phase 1: Base Infrastructure**

   - VPC and networking
   - Cloud SQL instance
   - Secret Manager setup

2. **Phase 2: Kubernetes Infrastructure**

   - GKE cluster
   - Node pools
   - Service accounts

3. **Phase 3: Application Deployment**

   - Kubernetes manifests
   - Service configuration
   - Health checks and monitoring

4. **Phase 4: Security and Compliance**
   - IAM roles
   - Network policies
   - Security scanning

## Success Criteria

1. All components deployed and healthy
2. Database properly configured and accessible
3. Secrets securely stored and accessible
4. Health checks passing
5. Monitoring and logging configured
6. Backup and recovery tested
7. Security controls verified

## Additional Considerations

1. Cost optimization
2. Disaster recovery
3. Upgrade strategy
4. Monitoring and alerting
5. Documentation requirements

## Deployment Tiers

### Basic Tier

- Suitable for development, testing, or small deployments
- Infrastructure:
  - Zonal GKE cluster (single zone)
  - Single Cloud SQL instance
  - Standard networking (no HA requirements)
  - Basic monitoring
- Specifications:
  - GKE: e2-standard-2 nodes (2 vCPU, 8GB RAM)
  - Cloud SQL: db-custom-1-3840 (1 vCPU, 3.75GB RAM)
  - Storage: 50GB SSD
- Estimated monthly cost: Lower cost, non-HA configuration
- Trade-offs:
  - No high availability
  - Limited scalability
  - Basic security controls

### Standard Tier

- Current specified configuration, suitable for production
- Infrastructure:
  - Regional GKE cluster (3 zones)
  - HA Cloud SQL with failover
  - Full security controls
  - Comprehensive monitoring
- Specifications:
  - As detailed in component sections above
  - Full backup and recovery
  - Standard SLAs
- Estimated monthly cost: Balanced cost and reliability
- Benefits:
  - High availability
  - Scalable architecture
  - Production-ready security

### Enterprise Tier

- Enhanced configuration for large-scale deployments
- Infrastructure:
  - Multi-regional deployment option
  - Cross-region failover
  - Advanced security features
  - Custom compliance controls
- Specifications:
  - GKE: Custom node sizes
  - Cloud SQL: Higher tier instances
  - Advanced monitoring and alerting
  - Custom backup strategies
- Additional features:
  - Multi-region load balancing
  - Custom compliance reporting
  - Enhanced support options
  - Advanced threat protection

## Operational Procedures

### Backup and Recovery

1. Automated Backups:

   - Daily Cloud SQL backups
   - GKE persistent volume snapshots
   - Configuration backups
   - Retention: 30 days standard

2. Disaster Recovery:

   - RTO (Recovery Time Objective): 4 hours
   - RPO (Recovery Point Objective): 24 hours
   - Regular DR testing schedule
   - Documented recovery procedures

3. Backup Testing:
   - Monthly restore validation
   - Quarterly DR exercises
   - Annual full recovery test

### Monitoring and Alerting

1. Key Metrics:

   - Cluster health metrics
   - Database performance
   - Application metrics
   - Network latency
   - Error rates

2. Alert Thresholds:

   - CPU utilization: 80%
   - Memory usage: 85%
   - Disk usage: 75%
   - Error rate: >1%
   - Response time: >2s

3. Monitoring Integration:
   - Cloud Monitoring dashboards
   - Custom metric collection
   - Log aggregation
   - Alert notification channels

### Maintenance Procedures

1. Regular Updates:

   - Monthly security patches
   - Quarterly version updates
   - Annual infrastructure review
   - Dependency updates

2. Upgrade Process:

   - Pre-upgrade testing
   - Backup verification
   - Rolling updates
   - Rollback procedures

3. Configuration Management:
   - Version controlled IaC
   - Change management process
   - Configuration validation
   - Audit logging

### Cost Management

1. Resource Optimization:

   - Regular right-sizing reviews
   - Cost allocation tracking
   - Idle resource detection
   - Auto-scaling optimization

2. Cost Controls:

   - Budget alerts
   - Resource quotas
   - Cost center tagging
   - Usage monitoring

3. Optimization Strategies:
   - Committed use discounts
   - Preemptible nodes where applicable
   - Storage tiering
   - Network cost optimization

HIGH PRIORITY:
Security
Sensitive variables (admin_password, database_password, license_key) are marked sensitive but no validation rules
No explicit pod security policies or security contexts defined
No network policies restricting pod-to-pod communication
Resource Management
No resource limits/requests on the Bindplane pods
No node affinity/anti-affinity rules for high availability
No PodDisruptionBudget for controlled updates
State Management
No explicit backup strategy for Bindplane state
No persistence configuration for Prometheus
MEDIUM PRIORITY:
Monitoring & Observability
No monitoring configuration for the GKE cluster
No logging configuration for the applications
No alerts configured for critical components
Configuration
Hardcoded values for some configurations that could be variables
No explicit TLS configuration for internal services
No environment-specific configurations
LOW PRIORITY:
Documentation
No architecture diagram
No explicit upgrade procedure documented
No disaster recovery procedures
Testing
No automated validation tests
No example configurations for different scenarios
No load testing guidance
Would you like me to:
Elaborate on any of these points?
Prioritize which should be addressed first?
Show examples of how to implement specific improvements?
