# terraform-aws-ecr

Terraform module that manages an [Amazon
ECR](https://aws.amazon.com/ecr/) repository. It creates a single container
image repository with image scanning and encryption enabled by default and can
attach a lifecycle policy to prune old images.

## Usage

```hcl
module "ecr" {
  source = "github.com/moveeeax/terraform-aws-ecr"

  name         = "app"
  scan_on_push = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                   | Description                                             | Type          | Default        | Required |
|------------------------|---------------------------------------------------------|---------------|----------------|:--------:|
| `name`                 | Name of the ECR repository.                             | `string`      | n/a            |   yes    |
| `image_tag_mutability` | Tag mutability. MUTABLE or IMMUTABLE.                   | `string`      | `"IMMUTABLE"`  |    no    |
| `scan_on_push`         | Scan images for vulnerabilities on push.               | `bool`        | `true`         |    no    |
| `encryption_type`      | Encryption type. AES256 or KMS.                        | `string`      | `"AES256"`     |    no    |
| `kms_key`              | ARN of the KMS key used when encryption_type is KMS.   | `string`      | `null`         |    no    |
| `force_delete`         | Delete the repository even if it contains images.      | `bool`        | `false`        |    no    |
| `lifecycle_policy`     | JSON lifecycle policy applied to the repository.       | `string`      | `null`         |    no    |
| `tags`                 | Tags applied to the repository.                        | `map(string)` | `{}`           |    no    |

## Outputs

| Name             | Description                                        |
|------------------|----------------------------------------------------|
| `id`             | Name of the repository.                            |
| `arn`            | ARN of the repository.                             |
| `name`           | Name of the repository.                            |
| `repository_url` | URL of the repository.                             |
| `registry_id`    | Registry ID where the repository was created.      |

## License

[MIT](LICENSE)
