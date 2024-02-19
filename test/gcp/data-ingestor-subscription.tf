module "google_pubsub_subscription_test" {
  source = "../../gcp/data-ingestor-subscription"

  name                  = "test-subscription"                                        # The name of the subscription coming from the data-ingestor project
  topic_name            = "test-topic"                                               # This topic should exist and created on the data-ingestor project
  environment           = "dev"                                                      # The environment that can be preview, preprod, dev or prod
  service_account_email = "dev-service-account@test-project.iam.gserviceaccount.com" # The service account email to be used for the subscription and your service
  push_endpoint         = "https://example-endpoint.com/push"                        # The endpoint to push messages to could be a cloud run, cloud function or any other http endpoint
  audience              = "https://example-endpoint.com"                             # The audience to be used for the subscription push endpoint, usually the same as the push endpoint
}
