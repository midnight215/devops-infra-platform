# ====== Subnets ======

resource "yandex_vpc_subnet" "dmz_subnet" {
  name           = "dmz-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.0.0/24"]
}

resource "yandex_vpc_subnet" "app1_subnet" {
  name           = "app1-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.1.0/24"]
}

resource "yandex_vpc_subnet" "app2_subnet" {
  name           = "app2-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.2.0/24"]
}

resource "yandex_vpc_subnet" "db1_subnet" {
  name           = "db1-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.3.0/24"]
}

resource "yandex_vpc_subnet" "db2_subnet" {
  name           = "db2-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.4.0/24"]
}

# ====== SECURITY GROUPS ======

# ---------- DMZ ----------
resource "yandex_vpc_security_group" "dmz_sg" {
  name       = "dmz-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 9000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- APP1 ----------
resource "yandex_vpc_security_group" "app1_sg" {
  name       = "app1-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 8428
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 8500
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 9000
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 9090
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 9100
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 9200
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 9300
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "UDP"
    port           = 8301
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "UDP"
    port           = 8302
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  ingress {
    protocol       = "UDP"
    port           = 8600
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- APP2 ----------
resource "yandex_vpc_security_group" "app2_sg" {
  name       = "app2-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [yandex_vpc_subnet.dmz_subnet.v4_cidr_blocks[0]]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- DB1 ----------
resource "yandex_vpc_security_group" "db1_sg" {
  name       = "db1-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [yandex_vpc_subnet.app1_subnet.v4_cidr_blocks[0]]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- DB2 ----------
resource "yandex_vpc_security_group" "db2_sg" {
  name       = "db2-sg"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = [yandex_vpc_subnet.app2_subnet.v4_cidr_blocks[0]]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
