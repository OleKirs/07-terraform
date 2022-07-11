variable family { default = "ubuntu-2004-lts" }
variable name_prefix { default = "" }
variable description { default = "create by terraform" }
variable instance_role { default = "all" }
variable users { default = "sysadmin"}
variable platform_id { default = "standard-v1" }
variable cores { default = "2" }
variable memory { default = "2" }
variable core_fraction { default = "100" }
variable image { default = "centos-7" }
variable boot_disk { default = "network-hdd" }
variable disk_size { default = "10" }
variable subnet_id { default = "" }
variable nat { default = "false" }
variable ipv6 { default = "false" }
variable instance_count { default = 1 }
variable count_offset { default = 0 } #start numbering from X+1 (e.g. name-1 if '0', name-3 if '2', etc.)
variable count_format { default = "%01d" } #server number format (-1, -2, etc.)
variable zone { default =  "" }
variable folder_id { default =  "" }

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

data "yandex_compute_image" "image" {
  family = var.image
}

resource "yandex_compute_instance" "instance" {

  count = var.instance_count

  name = "${var.name_prefix}${format(var.count_format, var.count_offset+count.index+1)}"
  hostname = "${var.name_prefix}-${format(var.count_format, var.count_offset+count.index+1)}"
 
  platform_id = var.platform_id
  description = var.description
  folder_id   = var.folder_id
  zone        = var.zone

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      type     = var.boot_disk
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
    ipv6      = var.ipv6
  }

  metadata = {
    user-data = "${var.users}:${file("~/.ssh/id_rsa.pub")}"
  }
}
