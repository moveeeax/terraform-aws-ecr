output "id" {
  description = "Name of the repository."
  value       = aws_ecr_repository.this.id
}

output "arn" {
  description = "ARN of the repository."
  value       = aws_ecr_repository.this.arn
}

output "name" {
  description = "Name of the repository."
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "URL of the repository, used as the image registry."
  value       = aws_ecr_repository.this.repository_url
}

output "registry_id" {
  description = "Registry ID where the repository was created."
  value       = aws_ecr_repository.this.registry_id
}
