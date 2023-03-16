resource "aws_api_gateway_rest_api" "minecraft" {
  body = file("${path.module}/api.json")

  name = "woodnet-backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}