module "pubsub_subscription_test_push" {
  source                = "../../gcp/data-ingestor-subscription"
  name                  = "example-push-subscription"
  topic_name            = "example-topic"
  environment           = "dev"
  subscription_type     = "push"
  service_account_email = "example-service-account@example.iam.gserviceaccount.com"
  push_endpoint         = "https://example-endpoint.com" # Required if subscription_type is "push"
  audience              = "https://example-endpoint.com" # Required if subscription_type is "push"
}

module "pubsub_subscription_test_pull" {
  source                     = "../../gcp/data-ingestor-subscription"
  name                       = "example-pull-subscription"
  topic_name                 = "example-topic"
  environment                = "dev"
  subscription_type          = "pull"
  service_account_email      = "example-service-account@example.iam.gserviceaccount.com"
  message_retention_duration = "1800s" # 30 minutes
  retain_acked_messages      = true
  ack_deadline_seconds       = 30
  expiration_ttl             = "604800s" # 7 days
  minimum_backoff            = "15s"
  enable_message_ordering    = false

}
