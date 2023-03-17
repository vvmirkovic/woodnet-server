resource "null_resource" "backend_url_env" {
  provisioner "local-exec" {
    command = "echo \"${module.backend.backend_url}\" > backend_url.txt"
  }
}