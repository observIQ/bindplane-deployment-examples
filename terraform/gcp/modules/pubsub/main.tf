# Google PubSub Topic
resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = var.topic_name

  #checkov:skip=CKV_GCP_83: "TODO(jsirianni): We can make this opt in"
}
