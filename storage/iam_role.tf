resource "aws_iam_role" "bucket_role" {
  provider = aws.source

  name        = "${var.bucket_name[0]}-iamrole"
  description = "S3 bucket role"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    }
  )

  tags = merge({ Name = var.bucket_name[0] }, local.tags)
}

resource "aws_iam_policy" "bucket_replication_policy" {
  provider = aws.source

  name        = "${aws_iam_role.bucket_role.name}-name"
  description = "AWS S3 bucket replication cross region replication policy"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:ListBucket",
            "s3:GetReplicationConfiguration",
            "s3:GetObjectVersionForReplication",
            "s3:GetObjectVersionAcl",
            "s3:GetObjectVersionTagging",
            "s3:GetObjectRetention",
            "s3:GetObjectLegalHold"
          ]
          Resource = [
            "arn:aws:s3:::${var.bucket_name[0]}",
            "arn:aws:s3:::${var.bucket_name[0]}/*"
          ]
        }
      ]
    }
  )
}
