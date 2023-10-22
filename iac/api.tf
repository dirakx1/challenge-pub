# Infrastructure needed for the api gateway

resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API created with Terraform"
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part  = "example"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.post.http_method

  type = "AWS_PROXY"
  uri  = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/your-lambda-function-arn/invocations"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [aws_api_gateway_integration.lambda]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name = "example"
}

output "invoke_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}
