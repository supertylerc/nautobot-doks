# TC: If this is the first VPC being created, a limitation in the DO API
#     will prevent it from being destroyed.  There is currently no workaround.
# https://github.com/digitalocean/terraform-provider-digitalocean/issues/472

# TC: Due to the above limitation, it is also not possible to modify the IP
#     range of the first VPC made.

# TC: A manual workaround would be to create a new VPC, then update it to be
#     the default VPC, then destroy your Terraform-managed infrastructure:
#         doctl vpcs create --ip-range 10.10.0.0/24 --region nyc3 --name default-nyc3
#         doctl vpcs update 2e9c7d37-e9ac-4f26-b911-a376bc334187 --default 
#    However, another option is to simply create a "dummy default" VPC before
#    you do anything in Terraform.  If it's the first VPC in a region, it's
#    automatically the default VPC.  However, be aware that to do this, you
#    need to reserve a /24 CIDR for each region in which you do this since a
#    DO VPC's IP range can't overlap with other range in the project.  This
#    also means that your "dummy default VPC" can't use subnets in your
#    TF-managed VPC.

resource "digitalocean_vpc" "vpc" {
  name     = var.vpc_name == "" ? "${var.region}-vpc" : var.vpc_name
  region   = var.region
  ip_range = var.vpc_ip_range
}
