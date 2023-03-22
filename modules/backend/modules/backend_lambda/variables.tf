variable "name" {}

variable "execution_role_arn" {}

variable "backend_arn" {}

variable "environment_vars" {
  default = {}
}

variable "timeout" {
  default = 10
}