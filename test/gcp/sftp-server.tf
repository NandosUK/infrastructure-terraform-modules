module "sftp-server" {
  source                = "../../gcp/sftp-server"
  project               = "infra-dev-sam-royal-38f6b201"
  name                  = "test"
  google_storage_bucket = "sftp"
  ssh-keys              = "testuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxuXzhRJCVKOybQVrfEhzW/NnFO96+l7v1RiXatux5gmA7y6DKN2cQt9DjxcGMR+rRqHIgMdwn+ABjPjCi+2YkC8GsdpxFithdTgogvdxjQm+jzKDqNb3RfNAGMwMEP4+VcFFHhZ1uf66cbjiPRE2E601ICaFucTjNYdSaVOq6GyfxKAyYyLCvKfmbSFtNBngT49A0XcG3FccVQpKrovJWXq1Ok31phQiBM/pCxRRjQefeqvGcX/XED+AZCaIEGY1fr7jQZBRc0h5NnTYJoByGP5CVclrUPmBkxXLHzNYatyB8iUyCAXXJ62AQc+EN4mG6A/9/3NdR6WOQSbTqb6kBZbBJjrFwp3vcFVV50TOxfcMpZvYsiQrSiBlEhKnpWk27iSY05FWANbNyTqDh63b+p/RLifYAjCmgRtDnz58XCUKG7q2uI1xvVVW671EWVqGrHP/NfkwwopOtP1NUohQenNAzWIhEA44ONad5cX3qoJN1tpksAHpwp6pZjw3rIjO6k0VPdXvJe2RabCaREhaVlVN4US98Tum+JrNL+OKUAFHumq1xHtNzxvbS1/J/cd6NXKguWWYVh3ir9GDr1YbMnWZgBX4lbIQiF6FiOD82zoDT5WPEsAK2YiDgrvS/g1lVSZnPq4kSVpcwoy3wO5tenHmSUrKMql3PeAjdq7gVrw=="
}
