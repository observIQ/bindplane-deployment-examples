output "instance_name" {
  description = "The name of the database instance"
  value       = google_sql_database_instance.instance.name
}

output "database_host" {
  description = "The host of the database"
  value       = google_sql_database_instance.instance.ip_address
}

output "database_name" {
  description = "The name of the database"
  value       = google_sql_database.database.name
}

output "private_ip_address" {
  description = "The private IP address of the database instance"
  value       = google_sql_database_instance.instance.private_ip_address
}

output "connection_name" {
  description = "The connection name of the instance, used in connection strings"
  value       = google_sql_database_instance.instance.connection_name
}

output "self_link" {
  description = "The URI of the created instance"
  value       = google_sql_database_instance.instance.self_link
}

# Don't output sensitive information like passwords
output "database_user" {
  description = "The database user name"
  value       = google_sql_user.user.name
}
