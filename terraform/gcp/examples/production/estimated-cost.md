# Estimated Monthly Costs

This document provides rough cost estimates for running the Bindplane infrastructure on GCP. Prices are in USD and based on us-central1 region.

## Core Infrastructure Costs

### GKE Cluster
- **Node Pool (n2-standard-4)**
  - vCPUs: 4 per node
  - Memory: 16GB per node
  - Nodes: Estimated 6 nodes
  - Cost per node: ~$146.00/month
  - **Total Node Cost**: ~$876.00/month

### Cloud SQL
- **Instance (db-custom-4-15360)**
  - vCPUs: 4
  - Memory: 15GB
  - Storage: 500GB
  - High availability: No
  - Automated backups: Yes
  - Cost: ~$280.00/month (instance) + ~$85.00/month (storage)
  - **Total Database Cost**: ~$365.00/month

### Networking
- **Cloud NAT**
  - Gateway: ~$1.00/month
  - Data processing: Variable based on usage
- **Load Balancer (for Ingress)**
  - Forwarding rules: ~$18.00/month
  - Data processing: Variable based on usage
- **VPC Network**
  - Egress: Variable based on usage (~$0.085/GB to internet)
  - **Estimated Network Cost**: ~$50.00/month (assumes moderate traffic)

### Storage and Messaging
- **Pub/Sub**
  - Message delivery: Variable based on usage
  - Storage: Variable based on retention
  - **Estimated Pub/Sub Cost**: ~$1.00/month (assumes light usage)

## Total Estimated Cost

- **Base Infrastructure**: ~$1,292.00/month
- **Variable Costs** (network traffic, Pub/Sub): $50-200/month depending on usage

## Cost Optimization Notes

1. **Autoscaling**
   - Costs can be lower when fewer nodes are needed
   - Current estimate assumes maximum node count (6 nodes)
   - Typical usage might average 2-3 nodes (~$438.00/month)

2. **Database Optimization**
   - Custom instance type allows precise CPU/memory allocation
   - Storage can be adjusted based on data retention needs
   - Consider enabling high availability for production (+~$280.00/month)

3. **Network Costs**
   - Internal traffic between GKE and Cloud SQL is free
   - Costs increase with external traffic and data transfer
   - Consider configuring Pub/Sub message retention based on needs

4. **Region Selection**
   - Prices based on us-central1
   - Other regions may have different pricing
   - Consider data residency requirements

## Monitoring and Billing

To monitor actual costs:
1. Set up Cloud Billing budgets and alerts
2. Use labels to track costs by component
3. Monitor GKE node utilization for scaling optimization
4. Review Cloud SQL performance metrics for right-sizing

Note: These estimates are approximations and actual costs will vary based on usage patterns, data transfer, and specific configuration choices.
