# v0.03.07 [07-03]

terraform {
#  cloud {
#    organization = "olekirs"
#
#    workspaces {
#      name = "stage"
#      name = "prod"
#    }
#  }
  # Moved to ./versions.tf
  #  required_providers {
  #    yandex = {
  #      source = "yandex-cloud/yandex"
  #    }
  #  }

  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket   = "olekirs-netology"
    region   = "ru-central1"
    key      = "terraform.tfstate"

    # Used \"AWS_ACCESS_KEY_ID\" and \"AWS_SECRET_ACCESS_KEY\" in user ENV
    #    access_key = "<идентификатор статического ключа>"
    #    secret_key = "<секретный ключ>"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
#  service_account_key_file = file("key.json")
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  zone      = var.yc_region
}


# Networks
#module "vpc" {
#  source        = "hamnsk/vpc/yandex"
#  version       = "0.5.0"
#  description   = "managed by terraform"
#  create_folder = length(var.yc_folder_id) > 0 ? false : true
#  yc_folder_id  = var.yc_folder_id
#  name          = terraform.workspace
#  subnets       = local.vpc_subnets[terraform.workspace]
#}

# Module VPC copyed to local system from https://github.com/hamnsk/terraform-yandex-vpc
module "vpc" {
  source  = "./modules/vpc"
  description = "managed by terraform"
  create_folder = length(var.yc_folder_id) > 0 ? false : true
  yc_folder_id = var.yc_folder_id
  name = terraform.workspace
  subnets = local.vpc_subnets[terraform.workspace]
}



# Instances
module "instances" {
  source         = "./modules/instances"
  instance_count = local.instances_instance_count[terraform.workspace]
  name_prefix    = "vm-c"

  subnet_id     = module.vpc.subnet_ids[0]
  zone          = var.yc_region
  folder_id     = module.vpc.folder_id
  image         = "ubuntu-2004-lts"
  platform_id   = local.instances_platform_id[terraform.workspace]
  description   = "Demo count"
  users         = "sysadmin"
  cores         = local.instances_cores[terraform.workspace]
  boot_disk     = local.instances_boot_disk[terraform.workspace]
  disk_size     = local.instances_disk_size[terraform.workspace]
  nat           = "true"
  memory        = "2"
  core_fraction = "100"
  depends_on = [
    module.vpc
  ]
}

module "instances_fe" {
  source         = "./modules/instances_fe"
  fe_name_prefix = "vm-fe-"
  fe_count       = local.instances_instance_fe_count[terraform.workspace]
  #  fe_names         = local.instances_instance_fe_names[terraform.workspace]
  fe_subnet_id     = module.vpc.subnet_ids[0]
  fe_zone          = var.yc_region
  fe_folder_id     = module.vpc.folder_id
  fe_image         = "ubuntu-2004-lts"
  fe_platform_id   = local.instances_platform_id[terraform.workspace]
  fe_description   = "Demo for_each"
  fe_users         = "sysadmin"
  fe_cores         = local.instances_cores[terraform.workspace]
  fe_boot_disk     = local.instances_boot_disk[terraform.workspace]
  fe_disk_size     = local.instances_disk_size[terraform.workspace]
  fe_nat           = "true"
  fe_memory        = "2"
  fe_core_fraction = "100"
  depends_on = [
    module.vpc
  ]
}

# Local Vars
locals {
  instances_platform_id = {
    stage = "standard-v1"
    prod  = "standard-v2"
  }
  instances_cores = {
    stage = 2
    prod  = 2
  }
  instances_boot_disk = {
    stage = "network-hdd"
    prod  = "network-ssd"
  }
  instances_disk_size = {
    stage = 10
    prod  = 20
  }
  instances_instance_count = {
    stage = 1
    prod  = 2
  }
  instances_instance_fe_count = {
    stage = 1
    prod  = 2
  }
  #  instances_instance_fe_names = {
  #    stage = ["vm-fe-01"]
  #    prod = ["vm-fe-01", "vm-fe-02"]
  #  }
  vpc_subnets = {
    stage = [
      {
        "v4_cidr_blocks" : [
          "10.128.0.0/24"
        ],
        "zone" : var.yc_region
      }
    ]
    prod = [
      {
        zone           = "ru-central1-a"
        v4_cidr_blocks = ["10.128.0.0/24"]
      },
      {
        zone           = "ru-central1-b"
        v4_cidr_blocks = ["10.129.0.0/24"]
      },
      {
        zone           = "ru-central1-c"
        v4_cidr_blocks = ["10.130.0.0/24"]
      }
    ]
  }
}

