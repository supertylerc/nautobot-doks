variable "vpc_name" {
  description = "Name of your DO VPC (default: $ {var.region}-vpc)"
  type        = string
  default     = ""
}

variable "vpc_ip_range" {
  description = "IPv4 CIDR for VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "region" {
  description = "Region in which to deploy resources"
  type        = string
  default     = "tor1"
}

variable "project_name" {
  description = "DigitalOcean project name"
  type        = string
  default     = "nautobot"
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
  default     = "netdevops"
}

variable "tags" {
  description = "The list of instance tags applied to the cluster."
  type        = list(string)
  default     = ["kubernetes"]
}

variable "kubernetes_version" {
  description = "The Kubernetes version"
  type        = string
  default     = "1.21."
}

variable "maintenance_policy_start_time" {
  description = "The start time in UTC of the maintenance window policy in 24-hour clock format / HH:MM notation"
  type        = string
  default     = "00:00"
}

variable "maintenance_policy_day" {
  description = "The day of the maintenance window policy"
  type        = string
  default     = "sunday"
}

variable "size" {
  description = "The slug identifier for the type of Droplet to be used as workers in the node pool."
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "max_nodes" {
  description = "Autoscaling maximum node capacity"
  type        = string
  default     = 1
}

variable "node_count" {
  description = "The number of Droplet instances in the node pool."
  type        = number
  default     = 1
}

variable "min_nodes" {
  description = "Autoscaling Minimum node capacity"
  type        = string
  default     = 1
}

variable "auto_scale" {
  description = "Enable cluster autoscaling"
  type        = bool
  default     = false
}

variable "auto_upgrade" {
  description = "Whether the cluster will be automatically upgraded"
  type        = bool
  default     = true
}

variable "node_labels" {
  description = "List of Kubernetes labels to apply to the nodes"
  type        = map(string)
  default = {
    "service" = "kubernetes"
  }
}

variable "node_tags" {
  description = "The list of instance tags applied to all nodes."
  type        = list(string)
  default     = ["kubernetes"]
}
