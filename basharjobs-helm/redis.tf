resource "helm_release" "redis" {
  name       = "redis-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "bitnami/redis"
  version    = "11.1.3"
  namespace  = "${var.namespace}"

  set {
    name  = "cluster.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set_string {
    name  = "service.annotations.prometheus\\.io/port"
    value = "9127"
  }
}