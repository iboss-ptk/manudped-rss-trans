resource "aws_api_gateway_rest_api" "manudped" {
  name        = "manudped"
  description = "manudped rss transformation"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "rss" {
  rest_api_id = "${aws_api_gateway_rest_api.manudped.id}"
  parent_id   = "${aws_api_gateway_rest_api.manudped.root_resource_id}"

  path_part = "rss"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = "${aws_api_gateway_rest_api.manudped.id}"
  resource_id   = "${aws_api_gateway_resource.rss.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.manudped.id}"
  resource_id = "${aws_api_gateway_method.get.resource_id}"
  http_method = "${aws_api_gateway_method.get.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.manudped_rss_trans.invoke_arn}"
}

resource "aws_api_gateway_deployment" "manudped" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
  ]

  rest_api_id       = "${aws_api_gateway_rest_api.manudped.id}"
  stage_name        = "live"
  stage_description = "${md5(file("api_gateway.tf"))}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.manudped_rss_trans.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.manudped.execution_arn}/*/*"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.manudped.invoke_url}"
}
