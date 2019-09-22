# terraform-file-gateway

A simple Terraform module for creating an AWS Storage Gateway NFS file share.

Creates the storage gateway, S3 bucket, and IAm role with appropriate permissions.

## Usage

```terraform
module "nfs" {
    source             = "github.com/robbytaylor/terraform-file-gateway"
    bucket_name        = "my-nfs-bucket"
    gateway_name       = "nfs-gateway"
    gateway_ip_address = "192.168.1.85"
}
```