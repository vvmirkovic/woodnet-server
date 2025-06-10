# ark variables 
variable "ark_asg_name" {
  default = null
}

variable "woodnet_server" {
  type    = bool
  default = false
}

variable "flashcards" {
  type    = bool
  default = false
}

variable "frontend_subdomain" {
  default = ""
}

variable "domain" {}

variable "env" {}

variable "name" {}