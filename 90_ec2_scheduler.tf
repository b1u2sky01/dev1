# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "start-ec2-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-start-ec2-scheduler-event"
  description         = "check-start-scheduler-event"
  schedule_expression = var.schedule_start_expression
  depends_on          = [aws_lambda_function.start_ec2_lambda]
}

resource "aws_cloudwatch_event_rule" "stop-ec2-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-stop-ec2-scheduler-event"
  description         = "check-stop-scheduler-event"
  schedule_expression = var.schedule_stop_expression
  depends_on          = [aws_lambda_function.stop_ec2_lambda]
}

# Cloudwatch event target
resource "aws_cloudwatch_event_target" "event-start-ec2-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-start-ec2-target"
  rule      = aws_cloudwatch_event_rule.start-ec2-scheduler-event[0].name
  arn       = aws_lambda_function.start_ec2_lambda[0].arn
}

resource "aws_cloudwatch_event_target" "event-stop-ec2-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-stop-ec2-target"
  rule      = aws_cloudwatch_event_rule.stop-ec2-scheduler-event[0].name
  arn       = aws_lambda_function.stop_ec2_lambda[0].arn
}


# IAM Role for Lambda function
resource "aws_iam_role" "scheduler_ec2_lambda" {
  count              = var.use_scheduler ? 1 : 0
  name               = "${local.default_tag}_scheduler_ec2_lambda"
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

data "aws_iam_policy_document" "ec2-access-scheduler" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:CreateTags",
      "rds:DescribeDBInstances",
      "rds:DescribeDBClusters",
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:ListTagsForResource",
      "rds:AddTagsToResource",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ec2-access-scheduler" {
  count  = var.use_scheduler ? 1 : 0
  name   = "scheduler-ec2-access-scheduler"
  path   = "/"
  policy = data.aws_iam_policy_document.ec2-access-scheduler.json
}

resource "aws_iam_role_policy_attachment" "ec2-access-scheduler" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_ec2_lambda[0].name
  policy_arn = aws_iam_policy.ec2-access-scheduler[0].arn
}

## create custom role

resource "aws_iam_policy" "scheduler_aws_lambda_basic_execution_role" {
  count       = var.use_scheduler ? 1 : 0
  name        = "scheduler_aws_lambda_basic_execution_role"
  path        = "/"
  description = "AWSLambdaBasicExecutionRole"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "ec2:CreateNetworkInterface",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DeleteNetworkInterface"
            ],
            "Resource": "*"
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "basic-exec-role" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_ec2_lambda[0].name
  policy_arn = aws_iam_policy.scheduler_aws_lambda_basic_execution_role[0].arn
}

# AWS Lambda need a zip file
data "archive_file" "aws-scheduler-ec2-start" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/ec2_instances_start.py"
  output_path = "${path.module}/scheduler_lambda/output/ec2_instances_start.zip"
}

data "archive_file" "aws-scheduler-ec2-stop" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/ec2_instances_stop.py"
  output_path = "${path.module}/scheduler_lambda/output/ec2_instances_stop.zip"
}

# AWS Lambda function
resource "aws_lambda_function" "start_ec2_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-ec2-start.output_path
  function_name = "start-ec2-lambda"
  role          = aws_iam_role.scheduler_ec2_lambda[0].arn
  handler       = "ec2_instances_start.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      AUTO_SCHEDULE_KEY   = "AutoScheduler"
      AUTO_SCHEDULE_VALUE = "true"
    }
  }
}

# AWS Lambda function
resource "aws_lambda_function" "stop_ec2_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-ec2-stop.output_path
  function_name = "stop-ec2-lambda"
  role          = aws_iam_role.scheduler_ec2_lambda[0].arn
  handler       = "ec2_instances_stop.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      AUTO_SCHEDULE_KEY   = "AutoScheduler"
      AUTO_SCHEDULE_VALUE = "true"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_start_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_ec2_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start-ec2-scheduler-event[0].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_stop_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_ec2_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop-ec2-scheduler-event[0].arn
}
