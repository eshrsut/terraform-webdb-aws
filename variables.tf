variable "public_key_path" {
  description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect.
Example: ~/.ssh/terraform.pub
DESCRIPTION
}

variable "key_name" {
  description = "Desired name of AWS key pair"
}

variable "aws_region" {
  description = "AWS region to launch web server"
  default     = "us-east-1"  #N Virginia
}

# Amazon Linux 2 64bit x86_64 (SSD)
variable "aws_amis" {
  default = {
    us-east-1 = "ami-0b898040803850657"
#    eu-west-1 = "ami-0bbc25e23a7640b9b"
#    us-west-1 = "ami-056ee704806822732"
#    us-west-2 = "ami-082b5a644766e0e6f"
  }
}
