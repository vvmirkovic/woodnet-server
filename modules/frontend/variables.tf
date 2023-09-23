variable "env" {}

variable "repo" {
    default = null
}

variable "github_token" {
    default = null
}

variable "domain" {}

variable "name" {}

variable "subdomain" {}

variable "bucket_name" {
    default = null
}

variable "create_cert" {
    default = true
}