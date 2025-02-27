# Estimated Monthly Cost for GCP Deployment

Based on the Terraform configuration, here's an approximate breakdown of the monthly costs for this deployment:

## GKE Cluster

- **Node Pool**: 1-3 e2-standard-2 instances (2 vCPU, 8GB RAM)
  - Base cost: ~$48.54/month per node
  - With sustained use discount: ~$35-40/month per node
  - Min nodes: 1, Max nodes: 3
- **Estimated cost**: $35-120/month depending on scaling

## Cloud SQL

- **Instance**: db-f1-micro (shared CPU, 0.6GB RAM)
  - Base cost: ~$9.37/month
  - Storage: 10GB SSD at ~$0.17/GB/month = $1.70/month
  - High availability (if enabled): Would double the instance cost
  - Backups: Minimal cost for 7-day retention
- **Estimated cost**: $11-22/month depending on HA setting

## Networking

- VPC Network: Free
- Cloud NAT: ~$0.044/hour = ~$32/month
- Private Service Access: Free
- Data transfer: Minimal within same region
- **Estimated cost**: $32-40/month

## Storage

- **Persistent Volumes**: 10GB for Prometheus
  - Standard storage: ~$0.04/GB/month = $0.40/month
- **Estimated cost**: $0.40-1/month

## Total Estimated Monthly Cost

- Minimum (1 node, no HA): ~$80-90/month
- Average (2 nodes, no HA): ~$120-140/month
- Maximum (3 nodes, with HA): ~$180-200/month

## Cost Optimization Recommendations

1. Use Spot VMs for non-critical workloads to reduce costs by up to 60-90%
2. Implement autoscaling based on actual usage patterns
3. Consider Committed Use Discounts for stable workloads (1 or 3-year commitments)
4. Optimize storage by using appropriate storage classes
5. Monitor and set budgets using GCP's budgeting tools

---

_These estimates are approximate and actual costs may vary based on usage patterns,_
_region, and any special pricing or discounts applied to your GCP account._
