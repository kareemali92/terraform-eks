resource "helm_release" "mysql" {
  name       = "mysql5.7-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "bitnami/mysql"
  version    = "6.14.10"
  namespace  = "${var.namespace}"

  set {
    name  = "image.tag"
    value = "5.7.31"
  }

  set {
    name  = "root.password"
    value = ""
  }

  set {
    name = "db.user"
    value = ""
  }

  set {
    name = "db.password"
    value = ""
  }

  set {
    name = "db.name"
    value = ""
  }

  set {
    name = "image.pullPolicy"
    value = "always"
  }

}