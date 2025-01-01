variable "region" {
  type        = list(string)
  description = "AWS region"
}

variable "bucket_name" {
  type        = list(string)
  description = "Names of S3 buckets"
}
