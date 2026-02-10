resource "helm_release" "flux_operator" {
  name             = "flux-operator"
  repository       = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart            = "flux-operator"
  create_namespace = true
  namespace        = "flux-system"
}

resource "kubectl_manifest" "flux_ssh_auth" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "flux-ssh-credentials"
      namespace = "flux-system"
    }
    type = "Opaque"
    data = {
      identity    = base64encode(var.ssh_private_key)
      known_hosts = base64encode(var.known_hosts)
    }
  })

  depends_on = [helm_release.flux_operator]
}

resource "helm_release" "flux_instance" {
  name       = "flux"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"
  namespace  = "flux-system"

  depends_on = [helm_release.flux_operator]

  # Pass configuration as a YAML object instead of individual 'set' blocks
  values = [
    yamlencode({
      instance = {
        distribution = {
          version = var.flux_version
        }
        sync = {
          url        = var.git_url
          ref        = var.git_branch
          path       = var.git_path
          pullSecret = kubectl_manifest.flux_ssh_auth.name
        }
      }
    })
  ]
}
