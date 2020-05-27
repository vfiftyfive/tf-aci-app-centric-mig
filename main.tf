#Deploys a Network Centric app, ie: 3 EPGs mapped to 3 different BD with contracts applied
locals {
  tenant_name = "mytenant"
  common_vrf  = "default"
  l3out       = "default"

  vm_network = { for epg in keys(var.app_epgs) : epg => "${format("%v|%v|%v", local.tenant_name, module.NET_v1_app.old_app.name, epg)}" }
}

provider "aci" {
  username = var.username
  # private_key = var.aci_private_key
  # cert_name   = var.aci_cert_name
  password = var.password
  url      = var.apic_url
  insecure = true
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

module "NET_v1_app" {
  source = "./modules/old_app"

  tenant_name               = local.tenant_name
  common_vrf                = local.common_vrf
  l3out                     = local.l3out
  app_bds                   = var.app_bds
  app_epgs                  = var.app_epgs
  epg_external              = var.epg_external
  vds_name                  = var.vds_name
  web_to_order_contract     = var.web_to_order_contract
  order_to_payment_contract = var.order_to_payment_contract
  payment_to_store_contract = var.payment_to_store_contract
}

module "app_vm" {
  source = "./modules/create_vm"

  vsphere_user            = var.vsphere_user
  vsphere_password        = var.vsphere_password
  vsphere_server          = var.vsphere_server
  vsphere_datacenter      = var.vsphere_datacenter
  vsphere_datastore       = var.vsphere_datastore
  vsphere_compute_cluster = var.vsphere_compute_cluster
  net_mgmt                = local.vm_network
  vsphere_template        = var.vsphere_template
  vm_name                 = var.vm_prefix
  vcpu                    = var.vcpu
  memory                  = var.memory
  folder                  = var.folder
  domain_name             = var.domain_name
  vm_ip_address_start     = var.vm_ip_address_start
  vm_cidr                 = var.vm_cidr
  gateway                 = var.gateway
  dns_list                = var.dns_list
  dns_search              = var.dns_search
  vm_depends_on           = module.NET_v1_app.network
  multi_nic               = "false"
  is_linked_clone         = "false"

}



