# ---------- PROVIDERS ----------
variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}
variable "zone" {
  type    = string
  default = "ru-central1-b"
}
variable "sa_terraform_key_path" {
  type    = string
  default = "../data/sa-terraform.secret.json"
}

# ---------- VM's ----------
variable "image_id" {
  description = "Image id for vm booting"
  type        = string
  # default     = "fd808e721rc1vt7jkd0o" # ubuntu 20.04 lts
  default     = "fd80bm0rh4rkepi5ksdi" # ubuntu 22.04 lts
}

variable "test_node_on" {
  type = bool
  default = false
}
