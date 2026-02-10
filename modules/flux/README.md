<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| helm | >= 2.9.0 |
| kubectl | >= 1.14.0 |

## Providers

| Name | Version |
|------|---------|
| helm | 3.1.1 |
| kubectl | >= 1.14.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| flux\_env | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.flux_instance](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.flux_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.flux_ssh_auth](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env\_vars | Map of environment variables to be used for labeling and tagging resources. Expected keys include: - "namespace": The namespace for resource labeling (default: "alnafi") - "stage": The stage/environment (e.g., "dev", "test", "prod - "delimiter": The delimiter to use in labels (default: "-") | `map(string)` | `{}` | no |
| flux\_version | Flux version to install (e.g., 2.4.0) | `string` | `"v2.4.0"` | no |
| git\_branch | n/a | `string` | `"main"` | no |
| git\_path | Path inside the repo to sync | `string` | `"./clusters/my-cluster"` | no |
| git\_url | SSH URL of the Git repo (e.g., ssh://git@github.com/org/repo.git) | `string` | n/a | yes |
| known\_hosts | Public SSH host key of the Git provider | `string` | `"github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"` | no |
| ssh\_private\_key | Private SSH key (PEM format) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->