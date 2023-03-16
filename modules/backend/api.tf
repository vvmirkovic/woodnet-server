resource "aws_api_gateway_rest_api" "woodnet" {
  body = file("${path.module}/api.json")

  name = "woodnet-backend"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "woodnet" {
  rest_api_id = aws_api_gateway_rest_api.woodnet.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.woodnet.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "woodnet" {
  deployment_id = aws_api_gateway_deployment.woodnet.id
  rest_api_id   = aws_api_gateway_rest_api.woodnet.id
  stage_name    = "woodnet"
}