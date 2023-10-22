# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create an SNS topic
resource "aws_sns_topic" "example" {
  name = "data_ingestion_topic"
}

# Create SQS queues for subscribers
resource "aws_sqs_queue" "subscriber_queue_1" {
  name = "subscriber_queue_1"
}

resource "aws_sqs_queue" "subscriber_queue_2" {
  name = "subscriber_queue_2"
}

# Subscribe SQS queues to the SNS topic
resource "aws_sns_topic_subscription" "subscription_1" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.subscriber_queue_1.arn
}

resource "aws_sns_topic_subscription" "subscription_2" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.subscriber_queue_2.arn
}

# Policy to allow SNS to publish to the topic
resource "aws_sns_topic_policy" "topic_policy" {
  arn = aws_sns_topic.example.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "SNS:Publish",
        Effect = "Allow",
        Principal = "*",
        Resource = aws_sns_topic.example.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.example.arn
          }
        }
      }
    ]
  })
}

# Output the ARNs of the SNS topic and SQS queues
output "sns_topic_arn" {
  value = aws_sns_topic.example.arn
}

output "sqs_queue_arns" {
  value = [aws_sqs_queue.subscriber_queue_1.arn, aws_sqs_queue.subscriber_queue_2.arn]
}

