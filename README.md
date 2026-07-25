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

Pin `source` to a tag or commit SHA (`...terraform-aws-ecr?ref=<sha>`) so a
change here cannot alter your registry configuration unreviewed.

A runnable example lives in [`examples/basic`](examples/basic).

### Defaults worth knowing

- `image_tag_mutability` defaults to `IMMUTABLE`. A mutable tag can be
  repointed at a different digest after it has been deployed, which breaks the
  "the image I scanned is the image I ran" guarantee. Only set `MUTABLE` if you
  genuinely need moving tags such as `latest`.
- `scan_on_push` defaults to `true` and `encryption_type` to `AES256`.
- `force_delete` defaults to `false`, so a repository still holding images will
  not be destroyed silently.
- `kms_key` is only honoured when `encryption_type = "KMS"`. Supplying it with
  `AES256` fails at plan time rather than quietly falling back to AES256.

### Lifecycle policy

`lifecycle_policy` takes the raw ECR policy document. It is checked at plan
time for valid JSON containing a `rules` array:

```hcl
module "ecr" {
  source = "github.com/moveeeax/terraform-aws-ecr"

  name = "app"

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 14 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 14
      }
      action = { type = "expire" }
    }]
  })
}
```

The module does not attach a repository policy. Without one, access is governed
by the caller's IAM policies within the owning account, which is the narrower
default; add `aws_ecr_repository_policy` yourself if you need cross-account
pulls.

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| aws       | >= 5.0   |

## Inputs

| Name                   | Description                                             | Type          | Default        | Required |
|------------------------|---------------------------------------------------------|---------------|----------------|:--------:|
| `name`                 | Name of the ECR repository. Checked against ECR name rules. | `string`      | n/a            |   yes    |
| `image_tag_mutability` | Tag mutability. MUTABLE or IMMUTABLE.                   | `string`      | `"IMMUTABLE"`  |    no    |
| `scan_on_push`         | Scan images for vulnerabilities on push.               | `bool`        | `true`         |    no    |
| `encryption_type`      | Encryption type. AES256 or KMS.                        | `string`      | `"AES256"`     |    no    |
| `kms_key`              | ARN of the KMS key. Requires `encryption_type = "KMS"`. | `string`      | `null`         |    no    |
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

## Development

```sh
terraform fmt -recursive
terraform init -backend=false && terraform validate
terraform test          # mocked AWS provider: no credentials, no API calls
tflint --init && tflint --recursive
```

`terraform test` uses `mock_provider`, which needs Terraform (or OpenTofu)
>= 1.7. That is a test-only requirement — the module itself still supports
>= 1.5.

## License

[MIT](LICENSE)
