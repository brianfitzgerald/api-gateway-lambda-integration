data "archive_file" "lambda_build" {
  type = "zip"
  source_file = "../lambda/src/${var.method_name}.js"
  output_path = "../lambda/build/${var.method_name}.zip"
}

resource "aws_lambda_function" "lambda_function" {
  filename = "${data.archive_file.lambda_build.output_path}"
  function_name = "${var.method_name}_lambda_${var.http_method}"
  role = "${var.lambda_role_name}"
  handler = "${var.method_name}.${lower(var.http_method)}"
  runtime = "nodejs6.10"
  source_code_hash = "${base64sha256(file("${data.archive_file.lambda_build.output_path}"))}"
  publish = true
}

resource "aws_api_gateway_method" "resource_method" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.http_method}"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "resource_integration" {
  rest_api_id = "${var.rest_api_id}"
  resource_id = "${var.resource_id}"
  http_method = "${var.http_method}"
  type = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.region}:${var.account_id}:function:${aws_lambda_function.lambda_function.function_name}/invocations"
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "allow_api_gateway" {
    function_name = "${aws_lambda_function.lambda_function.function_name}"
    statement_id = "AllowExecutionFromApiGateway"
    action = "lambda:InvokeFunction"
    principal = "apigateway.amazonaws.com"
    source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${var.rest_api_id}/*"
}
