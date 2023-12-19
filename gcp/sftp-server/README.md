# SFTP Server with Google Cloud Storage

This Terraform module allows you to create an SFTP server hosted in Google Cloud Platform (GCP) that stores files in a Google Cloud Storage bucket. It sets up the necessary infrastructure, including the VM instance, network, firewall rules, and more. It uses Thorntech's [SFTP Gateway](https://thorntech.com/sftp-gateway-for-google-cloud/).

## Prerequisites

Ensure the following APIs are enabled in your GCP project (the last two might not be necessary as we're managing through terraform, but I haven't tested without):

- `compute.googleapis.com`
- `deploymentmanager.googleapis.com`
- `runtimeconfig.googleapis.com`

## Accessing the SFTP Server

You can access the SFTP server using an SFTP client, such as [FileZilla](https://filezilla-project.org/) or the `sftp` command in your terminal. Use the following information:

- Host: The public IP address of the SFTP server (output from Terraform).
- Port: 22 (default SFTP port).
- Username: Use the same username as your SSH key.
- Password: Use your SSH key for authentication.

## Security Considerations

- Ensure that you protect your SSH key and do not share it with unauthorized users.
- Adjust the firewall rules (`google_compute_firewall`) as needed to control access to your SFTP server.

## Cleaning Up

To destroy the resources created by this Terraform module, run:

```bash
terraform destroy
```
