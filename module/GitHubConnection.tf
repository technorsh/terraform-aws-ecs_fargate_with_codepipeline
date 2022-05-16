resource "aws_codestarconnections_connection" "github_connection" {
  name          = "${var.ecr_repository}-connection" # GitHub Connection Name
  provider_type = "GitHub"
}