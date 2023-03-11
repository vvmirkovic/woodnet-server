resource "aws_api_gateway_rest_api" "minecraft" {
  body = file("${path.module}/src/api.json")

  name = "example"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}