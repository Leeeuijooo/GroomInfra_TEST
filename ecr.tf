resource "aws_ecr_repository" "groomecr" {
  name                 = "groomecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.groomecr.repository_url
}
