variable "cloud_id" {}
variable "folder_id" {}
variable "zone" {
  default = "ru-central1-a"
}
variable "sa_key" {}

variable "subnet_cidr" {
  default = "10.10.0.0/24"
}
variable "ssh_user" {
  default = "ubuntu"
}
variable "ssh_key_path" {}
variable "service_account_id" {
  type = string
}

