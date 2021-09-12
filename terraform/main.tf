variable "lambda_function_name" {
  type        = string
  default = "gosync_function"
}

variable "lambda_zip_package" {
  type        = string
  default = "../build/main.zip"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region                  = "eu-west-3"
  shared_credentials_file = "/Users/thierry/.aws/credentials"
  profile                 = "default"
}

resource "aws_iam_role" "iam_for_lambda_gosync" {
  name = "iam_for_lambda_gosync"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "gosync_function" {
  filename      = var.lambda_zip_package
  function_name = var.lambda_function_name
  role          = aws_iam_role.iam_for_lambda_gosync.arn
  handler       = "main"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(var.lambda_zip_package)

  runtime = "go1.x"

  environment {
    variables = {
      foo = "1 var env nécessaire"
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.nirvana_gosync_log_group,
  ]
}

resource "aws_cloudwatch_log_group" "nirvana_gosync_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda_gosync.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
