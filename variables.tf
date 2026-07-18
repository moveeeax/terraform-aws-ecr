variable "name" {
  description = "Name of the ECR repository."
  type        = string
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
}

variable "tags" {
  description = "Tags applied to the repository."
  type        = map(string)
  default     = {}
}
