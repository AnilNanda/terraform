#Define variable
variable "ami_id" {
  description = "AMI id of webserver ec2"
  default     = "ami-0d5eff06f840b45e9"
  type        = string
}