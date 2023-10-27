locals {
  cloud_id  = "b1gfqr43hq2rac0g60in"
  folder_id = "b1gbn2p3grvofh87hel0"
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
  service_account_key_file = file("./key.json")
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
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd808e721rc1vt7jkd0o"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1b.id
    nat       = true
  }

  metadata = {
    ssh-keys = "dima-batalov:${file("~/.ssh/kluster_rsa.pub")}"
  }
}
