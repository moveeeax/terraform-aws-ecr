# Requires Terraform >= 1.7 (or OpenTofu >= 1.7) for `mock_provider`.
# This is a test-only requirement; the module itself still supports >= 1.5, so
# versions.tf is deliberately left alone.

mock_provider "aws" {}

variables {
  name = "example-app"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = aws_ecr_repository.this.image_tag_mutability == "IMMUTABLE"
    error_message = "Tags must default to IMMUTABLE; mutable tags let a pushed digest be swapped underneath a deployed tag."
  }

  assert {
    condition     = aws_ecr_repository.this.image_scanning_configuration[0].scan_on_push == true
    error_message = "scan_on_push must default to true."
  }

  assert {
    condition     = aws_ecr_repository.this.encryption_configuration[0].encryption_type == "AES256"
    error_message = "Repositories must be encrypted at rest by default."
  }

  assert {
    condition     = aws_ecr_repository.this.force_delete == false
    error_message = "force_delete must default to false so a repository holding images is not silently destroyed."
  }

  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 0
    error_message = "No lifecycle policy resource should be created when lifecycle_policy is null."
  }
}

run "kms_encryption_passes_the_key_through" {
  command = plan

  variables {
    encryption_type = "KMS"
    kms_key         = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = aws_ecr_repository.this.encryption_configuration[0].kms_key == var.kms_key
    error_message = "kms_key must reach the repository when encryption_type is KMS."
  }
}

# A kms_key supplied alongside AES256 used to be dropped silently, leaving the
# caller believing they had CMK encryption. It must now fail at plan time.
run "kms_key_without_kms_encryption_is_rejected" {
  command = plan

  variables {
    encryption_type = "AES256"
    kms_key         = "arn:aws:kms:us-east-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [aws_ecr_repository.this]
}

run "valid_lifecycle_policy_is_attached" {
  command = plan

  variables {
    lifecycle_policy = <<-JSON
      {
        "rules": [
          {
            "rulePriority": 1,
            "description": "Expire untagged images after 14 days",
            "selection": {
              "tagStatus": "untagged",
              "countType": "sinceImagePushed",
              "countUnit": "days",
              "countNumber": 14
            },
            "action": { "type": "expire" }
          }
        ]
      }
    JSON
  }

  assert {
    condition     = length(aws_ecr_lifecycle_policy.this) == 1
    error_message = "A lifecycle policy resource should be created when lifecycle_policy is set."
  }
}

run "rejects_invalid_image_tag_mutability" {
  command = plan

  variables {
    image_tag_mutability = "SOMETIMES"
  }

  expect_failures = [var.image_tag_mutability]
}

run "rejects_invalid_encryption_type" {
  command = plan

  variables {
    encryption_type = "NONE"
  }

  expect_failures = [var.encryption_type]
}

run "rejects_malformed_lifecycle_policy_json" {
  command = plan

  variables {
    lifecycle_policy = "{ not json"
  }

  expect_failures = [var.lifecycle_policy]
}

run "rejects_lifecycle_policy_without_rules" {
  command = plan

  variables {
    lifecycle_policy = "{\"policy\": []}"
  }

  expect_failures = [var.lifecycle_policy]
}

run "rejects_invalid_repository_name" {
  command = plan

  variables {
    name = "Invalid_Name_With_Caps"
  }

  expect_failures = [var.name]
}
