# Estimated Daily and Monthly Costs

This document provides cost estimates based on actual usage data from a production deployment. Prices are in USD and do not include any discounts (e.g., sustained use discount, committed use discount).

## Cost Breakdown

| Service | Daily Cost | Monthly Cost (30 days) |
|---------|------------|----------------------|
| Compute Engine | $30.00 | $900.00 |
| Cloud SQL | $8.50 | $255.00 |
| Kubernetes Engine | $2.40 | $72.00 |
| Miscellaneous | $2.00 | $60.00 |
| **Total** | **$42.90** | **$1,287.00** |

## Notes

1. These costs are based on actual usage with:
   - 6 n2-standard-4 GKE nodes
   - db-custom-4-15360 Cloud SQL instance
   - Standard networking and storage

2. Actual costs may be lower due to:
   - Sustained use discounts (up to 30% off)
   - Committed use discounts (1 or 3-year commitments)
   - Region-specific pricing
   - Special pricing or credits

3. To monitor actual costs:
   - Set up Cloud Billing budgets and alerts
   - Use labels to track costs by component
   - Monitor GKE node utilization for scaling optimization
   - Review Cloud SQL performance metrics for right-sizing

