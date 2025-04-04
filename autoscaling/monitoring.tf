# SNS topic
resource "aws_sns_topic" "topic" {
  name = "${local.common_name}_snstopic"
}

resource "aws_sns_topic_subscription" "topicsub" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = "aoakyaw@protonmail.com"
}

# Cloudwatch alarm
resource "aws_cloudwatch_metric_alarm" "alarm" {
  alarm_name                = "${local.common_name}_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 50
  insufficient_data_actions = []

  alarm_actions = [
    aws_sns_topic.topic.arn
  ]
}
