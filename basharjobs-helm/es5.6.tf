resource "helm_release" "myelasticsearch" {
  name       = "elasticsearch5.6-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "bitnami/elasticsearch"
  version    = "12.8.0"
  namespace  = "${var.namespace}"

  set {
    name  = "image.tag"
    value = "5.6.16"
  }

  set {
    name = "image.pullPolicy"
    value = "always"
  }

}