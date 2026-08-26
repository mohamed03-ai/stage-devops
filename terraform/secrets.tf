resource "kubernetes_secret" "backend_secret" {
  metadata {
    name      = "backend-secret"
    namespace = "default"  # change if your backend deploys to a different namespace
  }

  data = {
    JWT_SECRET             = var.jwt_secret
    MONGO_URI              = var.mongo_uri
    CLOUDINARY_NAME        = var.cloudinary_name
    CLOUDINARY_API_KEY     = var.cloudinary_api_key
    CLOUDINARY_SECRET_KEY  = var.cloudinary_secret_key
  }

  type = "Opaque"
}