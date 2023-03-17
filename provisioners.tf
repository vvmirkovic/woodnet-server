resource "null_resource" "backend_url_env" {
  provisioner "local-exec" {
    command = "export BACKEND_URL=${module.backend.backend_url}"
  }
}