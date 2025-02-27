output "topic_name" {
  description = "The name of the PubSub topic"
  value       = google_pubsub_topic.topic.name
}
