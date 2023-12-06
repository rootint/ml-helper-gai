locals {
  metadata-ssh      = "dima-batalov:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEIW1RgZ1VaF5oVXaru7AbDT1+vUd+b7wIDpGtEKatEd dima-batalov@dima-batalov-x"
  metadata-userdata = file("./user-metadata.yaml")
}

# ---------- PROVIDERS ----------

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
  service_account_key_file = file(var.sa_terraform_key_path)
}

# ---------- NETWORK ----------

resource "yandex_vpc_network" "net-1" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet-1b" {
  network_id     = yandex_vpc_network.net-1.id
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["10.6.0.0/16"]
}

# ---------- DNS ----------

resource "yandex_dns_zone" "dns_zone" {
  zone             = "bibatalov.ru."
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.dns_zone.id
  name    = "bibatalov.ru."
  type    = "A"
  ttl     = 600
  data    = [yandex_compute_instance.vm-1.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.dns_zone.id
  name    = "gai.bibatalov.ru."
  type    = "A"
  ttl     = 600
  data    = [yandex_compute_instance.vm-1.network_interface.0.nat_ip_address]
}

# ---------- VM's ----------

resource "yandex_compute_instance" "vm-1" {
  name = "gateway"

  resources {
    cores  = 32
    memory = 32
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 64
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1b.id
    nat       = true
  }

  metadata = {
    ssh-keys  = local.metadata-ssh
    user-data = local.metadata-userdata
  }
}

output "vm-1-name" {
  value = yandex_compute_instance.vm-1.name
}

output "vm-1-public_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "vm-1-private_ip" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}
