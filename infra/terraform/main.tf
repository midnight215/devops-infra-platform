terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.108"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.sa_key
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# ====== VPC ======
resource "yandex_vpc_network" "main" {
  name = "devops-net"
}

locals {
  consul_tcp_ports = [8300, 8301, 8302, 8500, 8600]
  consul_udp_ports = [8301, 8302, 8600]
}

# ====== Compute Instances ======

# Consul
resource "yandex_compute_instance" "consul" {
  count    = 3
  name     = "consul-${count.index + 1}"
  hostname = "consul-${count.index + 1}"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app1_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app1_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
  
}

# Monitoring
resource "yandex_compute_instance" "monitoring" {
  name     = "monitoring"
  hostname = "monitoring"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app1_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app1_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}

# Logging
resource "yandex_compute_instance" "logging" {
  name     = "logging"
  hostname = "logging"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app1_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app1_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}

# VictoriaMetrics
resource "yandex_compute_instance" "victoriametrics" {
  name     = "victoriametrics"
  hostname = "victoriametrics"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app1_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app1_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}

# SonarQube
resource "yandex_compute_instance" "sonarqube" {
  name     = "sonarqube"
  hostname = "sonarqube"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app1_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app1_sg.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${file(var.ssh_key_path)}"
  }
}

# ====== Application Instance Group (Auto Scaling) ======

resource "yandex_compute_instance_group" "app_group" {
  name        = "app-group"
  description = "Группа инстансов для автоскейлинга"
  folder_id   = var.folder_id

  service_account_id = var.service_account_id

  instance_template {
    platform_id = "standard-v1"

    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = 20
      }
    }

    network_interface {
      subnet_ids         = [yandex_vpc_subnet.app1_subnet.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.app1_sg.id]
    }

    metadata = {
      ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 2
  }

  allocation_policy {
    zones = [var.zone]
  }
}

# ====== DMZ Load Balancer (VM) ======

resource "yandex_compute_instance" "dmz_lb" {
  name     = "dmz-lb"
  hostname = "dmz-lb"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.dmz_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.dmz_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_key_path)}"
  }
}

# ====== Ansible Inventory ======

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        consul = {
          hosts = {
            for i in range(length(yandex_compute_instance.consul)) :
            "consul${i + 1}" => {
              ansible_host = yandex_compute_instance.consul[i].network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.consul[i].network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        dmz-lb = {
          hosts = {
            dmz-lb = {
              ansible_host = yandex_compute_instance.logging.network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.logging.network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        "app" = {
          hosts = {
            for i in range(length(yandex_compute_instance_group.app_group.instances)) :
            "app${i + 1}" => {
              ansible_host = yandex_compute_instance_group.app_group.instances[i].network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance_group.app_group.instances[i].network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        monitoring = {
          hosts = {
            monitoring1 = {
              ansible_host = yandex_compute_instance.monitoring.network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.monitoring.network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        victoriametrics = {
          hosts = {
            victoriametrics = {
              ansible_host = yandex_compute_instance.victoriametrics.network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.victoriametrics.network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        logging = {
          hosts = {
            logging1 = {
              ansible_host = yandex_compute_instance.logging.network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.logging.network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
        sonarqube = {
          hosts = {
            sonarqube = {
              ansible_host = yandex_compute_instance.sonarqube.network_interface[0].nat_ip_address
              private_ip   = yandex_compute_instance.sonarqube.network_interface[0].ip_address
              ansible_user = "ubuntu"
            }
          }
        }
      }
    }
  })
}

