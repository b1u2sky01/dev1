# Cloudwatch event rule
resource "aws_cloudwatch_event_rule" "start-eks-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-start-eks-scheduler-event"
  description         = "check-start-scheduler-event"
  schedule_expression = var.schedule_start_expression
  depends_on          = [aws_lambda_function.start_eks_lambda]
}

resource "aws_cloudwatch_event_rule" "stop-eks-scheduler-event" {
  count               = var.use_scheduler ? 1 : 0
  name                = "${local.default_tag}-stop-eks-scheduler-event"
  description         = "check-stop-scheduler-event"
  schedule_expression = var.schedule_stop_expression
  depends_on          = [aws_lambda_function.stop_eks_lambda]
}

# Cloudwatch event target
resource "aws_cloudwatch_event_target" "event-start-eks-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-start-eks-target"
  rule      = aws_cloudwatch_event_rule.start-eks-scheduler-event[0].name
  arn       = aws_lambda_function.start_eks_lambda[0].arn
}

resource "aws_cloudwatch_event_target" "event-stop-eks-target" {
  count     = var.use_scheduler ? 1 : 0
  target_id = "event-stop-eks-target"
  rule      = aws_cloudwatch_event_rule.stop-eks-scheduler-event[0].name
  arn       = aws_lambda_function.stop_eks_lambda[0].arn
}


# IAM Role for Lambda function
resource "aws_iam_role" "scheduler_eks_lambda" {
  count = var.use_scheduler ? 1 : 0
  name  = "${local.default_tag}_scheduler_eks_lambda"
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

data "aws_iam_policy_document" "eks-access-scheduler" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:StopInstances",
      "ec2:StartInstances",
      "ec2:CreateTags",
      "eks:DescribeNodegroup",
      "eks:ListNodegroups",
      "eks:ListUpdates",
      "eks:DescribeUpdate",
      "eks:DescribeCluster",
      "eks:ListTagsForResource",
      "eks:UntagResource",
      "eks:TagResource",
      "eks:ListClusters"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "eks-access-scheduler" {
  count  = var.use_scheduler ? 1 : 0
  name   = "scheduler-eks-access-scheduler"
  path   = "/"
  policy = data.aws_iam_policy_document.eks-access-scheduler.json
}

resource "aws_iam_role_policy_attachment" "eks-access-scheduler" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_eks_lambda[0].name
  policy_arn = aws_iam_policy.eks-access-scheduler[0].arn
}

## create custom role

resource "aws_iam_policy" "scheduler_aws_eks_lambda_basic_execution_role" {
  count       = var.use_scheduler ? 1 : 0
  name        = "scheduler_aws_eks_lambda_basic_execution_role"
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
                "ec2:DeleteNetworkInterface",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:CreateAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "basic-eks-exec-role" {
  count      = var.use_scheduler ? 1 : 0
  role       = aws_iam_role.scheduler_eks_lambda[0].name
  policy_arn = aws_iam_policy.scheduler_aws_eks_lambda_basic_execution_role[0].arn
}

# AWS Lambda need a zip file
data "archive_file" "aws-scheduler-eks-start" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/eks_cluster_start.py"
  output_path = "${path.module}/scheduler_lambda/output/eks_cluster_start.zip"
}

data "archive_file" "aws-scheduler-eks-stop" {
  type        = "zip"
  source_file = "${path.module}/scheduler_lambda/src/eks_cluster_stop.py"
  output_path = "${path.module}/scheduler_lambda/output/eks_cluster_stop.zip"
}

# AWS Lambda function
resource "aws_lambda_function" "start_eks_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-eks-start.output_path
  function_name = "start-eks-lambda"
  role          = aws_iam_role.scheduler_eks_lambda[0].arn
  handler       = "eks_cluster_start.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      KEY                 = "eks:cluster-name"
      VALUE               = "eks-${local.default_tag}"
      AUTO_SCHEDULE_KEY   = "AutoScheduler"
      AUTO_SCHEDULE_VALUE = "true"

    }
  }
}

# AWS Lambda function
resource "aws_lambda_function" "stop_eks_lambda" {
  count         = var.use_scheduler ? 1 : 0
  filename      = data.archive_file.aws-scheduler-eks-stop.output_path
  function_name = "stop-eks-lambda"
  role          = aws_iam_role.scheduler_eks_lambda[0].arn
  handler       = "eks_cluster_stop.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  environment {
    variables = {
      KEY                 = "eks:cluster-name"
      VALUE               = "eks-${local.default_tag}"
      AUTO_SCHEDULE_KEY   = "AutoScheduler"
      AUTO_SCHEDULE_VALUE = "true"

    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_eks_start_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_eks_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start-eks-scheduler-event[0].arn
}

resource "aws_lambda_permission" "allow_cloudwatch_eks_stop_scheduler" {
  count         = var.use_scheduler ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_eks_lambda[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop-eks-scheduler-event[0].arn
}
