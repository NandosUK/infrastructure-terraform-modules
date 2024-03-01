locals {
  data_ingestor_subscriber = {
    preview = "serviceAccount:terraform@preview-data-ingestor-c0edc062.iam.gserviceaccount.com",
    preprod = "serviceAccount:terraform@preprod-data-ingestor-6ee5b6e2.iam.gserviceaccount.com",
    prod    = "serviceAccount:terraform@prod-data-ingestor-40f9b4fb.iam.gserviceaccount.com",
  }
}

resource "google_pubsub_topic_iam_member" "data_ingestor_subscriber" {
  topic  = var.topic
  role   = "roles/pubsub.subscriber"
  member = local.data_ingestor_subscriber[var.environment]
}
