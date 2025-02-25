# PubSub Module

This module creates a Pub/Sub topic.

## Usage

```hcl
module "pubsub" {
  source = "../../modules/pubsub"

  project_id = "your-project"
  topic_name = "your-topic"
}
```

## Requirements

- Pub/Sub API enabled
- Required IAM permissions:
  - pubsub.topics.create
  - pubsub.topics.update

## Inputs

| Name       | Description               | Type   | Default | Required |
| ---------- | ------------------------- | ------ | ------- | :------: |
| project_id | The project ID to host the topic in | string | -       |   yes    |
| topic_name | The name of the topic      | string | -       |   yes    |

## Outputs

| Name       | Description               |
| ---------- | ------------------------- |
| topic_name | The name of the topic      |
