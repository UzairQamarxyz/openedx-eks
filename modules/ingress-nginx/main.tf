module "public_ingress_nginx" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.23.0"

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn
  observability_tag = null

  enable_ingress_nginx = true

  ingress_nginx = {
    namespace = "ingress-nginx"
    values = [
      <<-EXTRA_VALUES
      fullnameOverride: "ingress-nginx"
      controller:
        ingressClass: "ingress-nginx"
        allowSnippetAnnotations: true

        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: app.kubernetes.io/name
                  operator: In
                  values:
                  - ingress-nginx
                - key: app.kubernetes.io/instance
                  operator: In
                  values:
                  - ingress-nginx
                - key: app.kubernetes.io/component
                  operator: In
                  values:
                  - controller
              topologyKey: "topology.kubernetes.io/zone"

        service:
          externalTrafficPolicy: Local
          annotations:
            service.beta.kubernetes.io/aws-load-balancer-name: "${var.cluster_name}-public-lb"
            service.beta.kubernetes.io/aws-load-balancer-type: "external"
            service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
            service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
            service.beta.kubernetes.io/aws-load-balancer-attributes: load_balancing.cross_zone.enabled=true
            service.beta.kubernetes.io/load-balancer-source-ranges: 0.0.0.0/0
        ingressClassResource:
          name: nginx-public
          enabled: true
          default: false
          controllerValue: k8s.io/ingress-nginx
    EXTRA_VALUES
    ]
  }
  tags = module.ingress_nginx_env.tags
}
