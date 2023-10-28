locals {
  cloud_id  = "b1gfqr43hq2rac0g60in"
  folder_id = "b1gbn2p3grvofh87hel0"
  sa_terraform_key_path = "../data/sa-terraform.secret.json"
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
  cloud_id                 = local.cloud_id
  folder_id                = local.folder_id
  zone                     = "ru-central1-b"
  service_account_key_file = file(local.sa_terraform_key_path)
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

# ---------- VM's ----------

resource "yandex_compute_instance" "vm-1" {
  name = "gateway"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd808e721rc1vt7jkd0o"
      size = 64
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1b.id
    nat       = true
  }

  metadata = {
    ssh-keys = "dima-batalov:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEIW1RgZ1VaF5oVXaru7AbDT1+vUd+b7wIDpGtEKatEd dima-batalov@dima-batalov-x"
    user-data = file("./user-metadata.yaml")
  }
}
