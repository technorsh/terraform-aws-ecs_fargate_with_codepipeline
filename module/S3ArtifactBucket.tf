resource "aws_s3_bucket" "this" {
  bucket = "${var.ecr_repository}-${var.region}-codepipeline"
}