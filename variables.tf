variable "name" {
  description = "Name of the ECR repository."
  type        = string

  # Mirrors the repositoryName constraints documented for the ECR
  # CreateRepository API, so a bad name fails at plan time instead of apply.
  validation {
    condition     = can(regex("^(?:[a-z0-9]+(?:[._-][a-z0-9]+)*/)*[a-z0-9]+(?:[._-][a-z0-9]+)*$", var.name)) && length(var.name) >= 2 && length(var.name) <= 256
    error_message = "name must be 2-256 characters of lowercase letters, numbers, and the separators . _ - / (separators may not lead, trail, or repeat)."
  }
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository. Either MUTABLE or IMMUTABLE."
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Whether images are scanned for vulnerabilities after being pushed."
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository. Either AES256 or KMS."
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "encryption_type must be either AES256 or KMS."
  }
}

variable "kms_key" {
  description = "ARN of the KMS key used when encryption_type is KMS."
  type        = string
  default     = null
}

variable "force_delete" {
  description = "Whether to delete the repository even if it still contains images."
  type        = bool
  default     = false
}

variable "lifecycle_policy" {
  description = "JSON lifecycle policy applied to the repository. Null skips the policy."
  type        = string
  default     = null

  validation {
    condition     = var.lifecycle_policy == null || can(jsondecode(var.lifecycle_policy))
    error_message = "lifecycle_policy must be valid JSON."
  }

  validation {
    # tolist(null) succeeds (it evaluates to null) even though can() reports
    # no error, so a `"rules": null` payload would otherwise slip past this
    # check and only fail once it reaches the ECR API at apply time. The
    # explicit != null guards that case.
    condition = var.lifecycle_policy == null || (
      can(jsondecode(var.lifecycle_policy)["rules"]) &&
      jsondecode(var.lifecycle_policy)["rules"] != null &&
      can(tolist(jsondecode(var.lifecycle_policy)["rules"]))
    )
    error_message = "lifecycle_policy must be a JSON object with a \"rules\" array, e.g. {\"rules\":[{\"rulePriority\":1,...}]}. Anything else is rejected by the ECR API at apply time."
  }
}

variable "tags" {
  description = "Tags applied to the repository."
  type        = map(string)
  default     = {}
}
