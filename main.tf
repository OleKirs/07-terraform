# 07-01
provider "yandex" {
  token     = "key.json"
  cloud_id  = "b1gh06cb9in7v03k56qm"
  folder_id = "b1ghl566ok47p1fivpn9"
  zone      = "ru-central1-a"
}

# Networks

resource "yandex_vpc_network" "netology_net" {
  name = "netology_net"
}

resource "yandex_vpc_subnet" "snet_172_17_4_0_22" {
  name           = "snet_172_17_4_0_22"
  network_id     = resource.yandex_vpc_network.netology_net.id
  v4_cidr_blocks = ["172.17.4.0/22"]
  zone           = "ru-central1-a"
}

# VMs

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "vm" {
  name        = "ubu01"
  hostname    = "ubu01.netology.test"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.snet_172_17_4_0_22.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }
}

