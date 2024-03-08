output "job_id" {
  description = "Job ID of the Cloud Run Job"
  value       = google_cloud_run_v2_job.default.id
}

output "job_uid" {
  description = "Server assigned unique identifier for the Execution. The value is a UUID4 string and guaranteed to remain unchanged until the resource is deleted."
  value       = google_cloud_run_v2_job.default.uid
}
