variable fe_family { default = "ubuntu-2004-lts" }
variable fe_name_prefix { default = "" }
variable fe_description { default = "create by terraform" }
variable fe_instance_role { default = "all" }
variable fe_users { default = "sysadmin"}
variable fe_platform_id { default = "standard-v1" }
variable fe_cores { default = "2" }
variable fe_memory { default = "2" }
variable fe_core_fraction { default = "100" }
variable fe_image { default = "centos-7" }
variable fe_boot_disk { default = "network-hdd" }
variable fe_disk_size { default = "10" }
variable fe_subnet_id { default = "" }
variable fe_nat { default = "false" }
variable fe_ipv6 { default = "false" }
variable fe_instance_count { default = 1 }
variable fe_count_offset { default = 0 } #start numbering from X+1 (e.g. name-1 if '0', name-3 if '2', etc.)
variable fe_count_format { default = "%01d" } #server number format (-1, -2, etc.)
variable fe_zone { default =  "" }
variable fe_folder_id { default =  "" }
variable fe_count { default =  "1" }

terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.61.0"
    }
  }
}

data "yandex_compute_image" "image_fe" {
  family = var.fe_image
}

resource "yandex_compute_instance" "instance_fe" {
  
  for_each = toset([for s in (range("${var.fe_count}")) : "${var.fe_name_prefix}${var.fe_count_offset+s+1}"])

  name        = "${each.value}"
  hostname    = "${each.value}"

  platform_id = var.fe_platform_id
  description = var.fe_description
  folder_id   = var.fe_folder_id
  zone        = var.fe_zone

  resources {
    cores         = var.fe_cores
    memory        = var.fe_memory
    core_fraction = var.fe_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image_fe.id
      type     = var.fe_boot_disk
      size     = var.fe_disk_size
    }
  }

  network_interface {
    subnet_id = var.fe_subnet_id
    nat       = var.fe_nat
    ipv6      = var.fe_ipv6
  }

  metadata = {
    user-data = "${var.fe_users}:${file("~/.ssh/id_rsa.pub")}"
  }
}
