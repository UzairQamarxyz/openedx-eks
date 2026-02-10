output "alerts_topic_arn" {
  value       = aws_sns_topic.this["alerts"].arn
  description = "The name of topic created for alerts"
}

output "critical_alerts_topic_arn" {
  value       = aws_sns_topic.this["critical_alerts"].arn
  description = "The name of topic created for critical alerts"
}

output "events_topic_arn" {
  value       = aws_sns_topic.this["events"].arn
  description = "The name of the topic created for events"
}

output "pipeline_events_topic_arn" {
  value       = aws_sns_topic.this["pipeline_events"].arn
  description = "The name of the topic created for pipeline events"
}
