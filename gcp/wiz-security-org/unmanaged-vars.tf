variable "service_account_project_id" {
  type    = string
  default = ""
}

variable "wiz_service_account_name" {
  type    = string
  default = "wiz-service-account"
}

variable "project_service_wait_time" {
  type        = string
  default     = "10s"
  description = "Amount of time to wait after enabling the required Google Cloud APIs"
}

variable "required_apis" {
  type = map(string)
  default = {
    apikeys              = "apikeys.googleapis.com"
    appengine            = "appengine.googleapis.com"
    bigquery             = "bigquery.googleapis.com"
    bigquerystorage      = "bigquerystorage.googleapis.com"
    bigtableadmin        = "bigtableadmin.googleapis.com"
    cloudapis            = "cloudapis.googleapis.com"
    cloudasset           = "cloudasset.googleapis.com"
    cloudfunctions       = "cloudfunctions.googleapis.com"
    cloudkms             = "cloudkms.googleapis.com"
    cloudresourcemanager = "cloudresourcemanager.googleapis.com"
    composer             = "composer.googleapis.com"
    compute              = "compute.googleapis.com"
    container            = "container.googleapis.com"
    dns                  = "dns.googleapis.com"
    file                 = "file.googleapis.com"
    iam                  = "iam.googleapis.com"
    identitytoolkit      = "identitytoolkit.googleapis.com"
    memcache             = "memcache.googleapis.com"
    policyanalyzer       = "policyanalyzer.googleapis.com"
    pubsub               = "pubsub.googleapis.com"
    recommender          = "recommender.googleapis.com"
    redis                = "redis.googleapis.com"
    run                  = "run.googleapis.com"
    secretmanager        = "secretmanager.googleapis.com"
    securitycenter       = "securitycenter.googleapis.com"
    servicemanagement    = "servicemanagement.googleapis.com"
    serviceusage         = "serviceusage.googleapis.com"
    spanner              = "spanner.googleapis.com"
    sqladmin             = "sqladmin.googleapis.com"
    servicenetworking    = "servicenetworking.googleapis.com"
    firebaserules        = "firebaserules.googleapis.com"
    certificatemanager   = "certificatemanager.googleapis.com"
    accesscontextmanager = "accesscontextmanager.googleapis.com"
    essentialcontacts    = "essentialcontacts.googleapis.com"
    accessapproval       = "accessapproval.googleapis.com"
    discoveryengine      = "discoveryengine.googleapis.com"
    dialogflow           = "dialogflow.googleapis.com"
    dlp                  = "dlp.googleapis.com"
    storagetransfer      = "storagetransfer.googleapis.com"
  }
}
