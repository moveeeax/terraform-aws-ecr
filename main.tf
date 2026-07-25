resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_type == "KMS" ? var.kms_key : null
  }

  tags = var.tags

  # Cross-variable checks live here rather than in variable `validation` blocks
  # so the module keeps working on Terraform < 1.9, which cannot reference
  # another variable from inside a validation condition.
  lifecycle {
    precondition {
      condition     = var.kms_key == null || var.encryption_type == "KMS"
      error_message = "kms_key is only honoured when encryption_type is \"KMS\". Set encryption_type = \"KMS\" or remove kms_key; otherwise the key is silently ignored and the repository is encrypted with AES256."
    }
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  count = var.lifecycle_policy != null ? 1 : 0

  repository = aws_ecr_repository.this.name
  policy     = var.lifecycle_policy
}
