variable "lambda_role_name" {
    type = "string"
}

variable "resource_id" {
    type = "string"
}

variable "account_id" {
    type = "string"
}

variable "rest_api_id" {
    type = "string"
}

variable "region" {
    type = "string"
}

variable "method_name" {
    type = "string"
}

variable "http_method" {
    type = "string"
    default = "GET"
}
