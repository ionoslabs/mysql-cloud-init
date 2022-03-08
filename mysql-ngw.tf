# Terraform IONOS mysql DB behind nat gw

terraform {
  required_providers {
    ionoscloud = {
      source  = "ionos-cloud/ionoscloud"
      # version = "6.1.5"
    }
  }
}

provider "ionoscloud" {
  username = var.ionos_username
  password = var.ionos_password
}

resource "ionoscloud_datacenter" "terraform-wp-db-external" {
  location    = "us/ewr"
  name        = "terraform-db1"
  description = "terraform sandbox bash script"
}

# Internal LAN network 192.168.10.x
resource "ionoscloud_lan" "terraform-lan-1" {
  datacenter_id = ionoscloud_datacenter.terraform-wp-db-external.id
  name          = "lan"
  public        = false
}


resource "ionoscloud_ipblock" "mysqltest" {
  location = "us/ewr"
  size     = 1
}

resource "ionoscloud_natgateway" "ngw" {
  datacenter_id = ionoscloud_datacenter.terraform-wp-db-external.id
  name = "ngw"
  public_ips = ["${ionoscloud_ipblock.mysqltest.ips[0]}"]
  lans {
    id = ionoscloud_lan.terraform-lan-1.id
    gateway_ips = [ "192.168.10.1"]
  }
}

resource "ionoscloud_natgateway_rule" "all-out" {
  datacenter_id = ionoscloud_datacenter.terraform-wp-db-external.id
  natgateway_id = ionoscloud_natgateway.ngw.id
  name          = "All-out"
  type          = "SNAT"
  protocol      = "ALL"
  source_subnet = "192.168.10.0/24"
  public_ip     = "${ionoscloud_ipblock.mysqltest.ips[0]}"
  target_subnet = "0.0.0.0/0"
  depends_on = [
    ionoscloud_natgateway.ngw
  ]
}

# note user data section, base64 encodes the cloud-init-wp-install.yaml file and places in cloud-init user_data for first boot run
  #Mysql DB server creation 
resource "ionoscloud_server" "terraform-db1" {
  name              = "terraform-db1"
  datacenter_id     = ionoscloud_datacenter.terraform-wp-db-external.id
  cores             = 2
  ram               = 4 * 1024
  cpu_family        = "AMD_OPTERON"
  availability_zone = "AUTO"
  image_name        = "ubuntu"
  image_password = "123456789"
  # path below is the path to the public key already created you want to copy to the server instance, enter your local path
  ssh_key_path = [
    "/home/seth/.ssh/id_ed25519.pub",
   ]
  depends_on = [
    ionoscloud_lan.terraform-lan-1,
    ionoscloud_natgateway.ngw,
    ionoscloud_natgateway_rule.all-out
  ]

  nic {
    lan             = ionoscloud_lan.terraform-lan-1.id
    dhcp            = false
    firewall_active = false
    name            = "lan"
    ips = ["192.168.10.20"]
  } 


  volume {
    name      = "terraform-db1-vol1"
    size      = 50
    disk_type = "HDD"
    user_data = "${filebase64("mysql-cloud-init.yaml")}"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
  
}