# Terminal approach
# helm repo add argo https://argoproj.github.io/argo-helm
# helm repo update
# helm install argocd -n argocd --create-namespace argo/argo-cd --version 3.35.4 -f terraform/values/argocd.yaml

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "3.35.4"

  values = [file("values/argocd.yaml")]
}

# check helm status for argocd
# helm status argodcd -n argocd
# helm list -A
# kubectl get pods -n argocd

# check for default argocd admin password (argocd-initial-admin-secret)
# kubectl get secrets -n argocd
# kubectl get secrets argocd-initial-admin-secret -o yaml -n argocd   (base64 encoded)
# to decoded, use following command
# echo "SEpSVXo4Y3ZFRW8teDAxYQ==" | base64 -d   
# HJRUz8cvEEo-x01a (copy without the % at the back, % means end of string)
# port forward service to local:8080
# kubectl port-forward svc/argocd-server -n argocd 7080:80 (save 8080 for application local testing)