variable "vpc_id" {
  default = "vpc-0f1375ad7aab8cf2a"
}

variable "ami_id" {
  default = "ami-05fa00d4c63e32376"
}

variable "subnets" {
  default = [
              "subnet-04e73be4ab42d2264",
              "subnet-060ec1206ca966d75"
  ]
}

variable "server_name" {
  default = "Minecraft Server"
}