variable "env_vars" {
  type        = map(string)
  description = <<EOT
Map of environment variables to be used for labeling and tagging resources.
Expected keys include:
- "namespace": The namespace for resource labeling (default: "alnafi")
- "stage": The stage/environment (e.g., "dev", "test", "prod
- "delimiter": The delimiter to use in labels (default: "-")
EOT
  default     = {}
}

variable "flux_version" {
  description = "Flux version to install (e.g., 2.4.0)"
  type        = string
  default     = "v2.4.0"
}

variable "git_url" {
  description = "SSH URL of the Git repo (e.g., ssh://git@github.com/org/repo.git)"
  type        = string
}

variable "git_branch" {
  type    = string
  default = "main"
}

variable "git_path" {
  description = "Path inside the repo to sync"
  type        = string
  default     = "./clusters/my-cluster"
}

variable "ssh_private_key" {
  description = "Private SSH key (PEM format)"
  type        = string
  sensitive   = true
}

variable "known_hosts" {
  description = "Public SSH host key of the Git provider"
  type        = string
  default     = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl"
}
