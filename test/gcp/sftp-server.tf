module "sftp-server" {
  source                = "../../gcp/sftp-server"
  project               = "infra-dev-sam-royal-38f6b201"
  name                  = "test"
  google_storage_bucket = "sftp"
}
