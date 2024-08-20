variable "origin-id" {
  description = "The unique identifier of the origin request policy"
  type        = string
}


variable "cdn-bucket-name" {
  description = "The name of the S3 bucket to be used as the origin of the CloudFront distribution"
  type        = string
}