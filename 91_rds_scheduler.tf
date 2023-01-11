# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "start-rds-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-start-rds-scheduler-event"
  description         = "check-start-scheduler-event"
  schedule_expression = var.schedule_start_expression
  depends_on          = [aws_lambda_function.start_rds_lambda]
}

resource "aws_cloudwatch_event_rule" "stop-rds-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-stop-rds-scheduler-event"
  description         = "check-stop-scheduler-event"
  schedule_expression = var.schedule_stop_expression
  depends_on          = [aws_lambda_function.stop_rds_lambda]
}

# Cloudwatch event target
resource "aws_cloudwatch_event_target" "event-start-rds-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-start-rds-target"
  rule      = aws_cloudwatch_event_rule.start-rds-scheduler-event[0].name
  arn       = aws_lambda_function.start_rds_lambda[0].arn
}

resource "aws_cloudwatch_event_target" "event-stop-rds-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-stop-rds-target"
  rule      = aws_cloudwatch_event_rule.stop-rds-scheduler-event[0].name
  arn       = aws_lambda_function.stop_rds_lambda[0].arn
}

# IAM Role for Lambda function
resource "aws_iam_role" "scheduler_rds_lambda" {
  count = var.use_scheduler ? 1 : 0
  name  = "${local.default_tag}_scheduler_rds_lambda"
  #  permissions_boundary = var.permissions_boundary != "" ? var.permissions_boundary : ""
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

data "aws_iam_policy_document" "rds-access-scheduler" {
  count = var.use_scheduler ? 1 : 0
  statement {
    actions = [
      "rds:DescribeDBClusterParameters",
      "rds:StartDBCluster",
      "rds:StopDBCluster",
      "rds:DescribeDBEngineVersions",
      "rds:DescribeGlobalClusters",
      "rds:DescribePendingMaintenanceActions",
      "rds:DescribeDBLogFiles",
      "rds:StopDBInstance",
      "rds:StartDBInstance",
      "rds:DescribeReservedDBInstancesOfferings",
      "rds:DescribeReservedDBInstances",
      "rds:ListTagsForResource",
      "rds:DescribeValidDBInstanceModifications",
      "rds:DescribeDBInstances",
      "rds:DescribeSourceRegions",
      "rds:DescribeDBClusterEndpoints",
      "rds:DescribeDBClusters",
      "rds:DescribeDBClusterParameterGroups",
      "rds:DescribeOptionGroups",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "rds-access-scheduler" {
  count  = var.use_scheduler ? 1 : 0
  name   = "scheduler-rds-access-scheduler"
  path   = "/"
  policy = data.aws_iam_policy_document.rds-access-scheduler[0].json
}

resource "aws_iam_role_policy_attachment" "rds-access-scheduler" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_rds_lambda[0].name
  policy_arn = aws_iam_policy.rds-access-scheduler[0].arn
}

## create custom role
resource "aws_iam_policy" "scheduler_aws_rds_lambda_basic_execution_role" {
  count       = var.use_scheduler ? 1 : 0
  name        = "scheduler_aws_rds_lambda_basic_execution_role"
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
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic-rds-exec-role" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_rds_lambda[0].name
  policy_arn = aws_iam_policy.scheduler_aws_rds_lambda_basic_execution_role[0].arn
}

# AWS Lambda need a zip file
data "archive_file" "aws-scheduler-rds-start" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/rds_cluster_start.py"
  output_path = "${path.module}/scheduler_lambda/output/rds_cluster_start.zip"
}

data "archive_file" "aws-scheduler-rds-stop" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/rds_cluster_stop.py"
  output_path = "${path.module}/scheduler_lambda/output/rds_cluster_stop.zip"
}

# AWS Lambda function
resource "aws_lambda_function" "start_rds_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-rds-start.output_path
  function_name = "start-rds-lambda"
  role          = aws_iam_role.scheduler_rds_lambda[0].arn
  handler       = "rds_cluster_start.lambda_handler"
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
resource "aws_lambda_function" "stop_rds_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-rds-stop.output_path
  function_name = "stop-rds-lambda"
  role          = aws_iam_role.scheduler_rds_lambda[0].arn
  handler       = "rds_cluster_stop.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      AUTO_SCHEDULE_KEY   = "AutoScheduler"
      AUTO_SCHEDULE_VALUE = "true"
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_rds_start_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_rds_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start-rds-scheduler-event[0].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_rds_stop_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_rds_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop-rds-scheduler-event[0].arn
}
