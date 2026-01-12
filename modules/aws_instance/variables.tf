variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "security_groups" {
  description = "List of security group IDs"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs for instances (must match instance_count)"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for instance initialization"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to instances"
  type        = map(string)
  default     = {}
}

variable "root_block_device" {
  description = "Root block device configuration"
  type = list(object({
    volume_size = number
    volume_type = string
  }))
  default = [{
    volume_size = 8
    volume_type = "gp2"
  }]
}
