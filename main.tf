#Deploys a Network Centric app, ie: 3 EPGs mapped to 3 different BD with contracts applied
locals {
  tenant_name   = "mytenant"
  common_vrf    = "default"
  l3out         = "default"
  app_single_bd = "app_centric_bd"
  app_subnet    = "10.15.2.1/16"
}



provider "aci" {
  username = var.username
  # private_key = var.aci_private_key
  # cert_name   = var.aci_cert_name
  password = var.password
  url      = var.apic_url
  insecure = true
}

module "NET_v2_app" {
  source = "./modules/new_app"

  tenant_name               = local.tenant_name
  common_vrf                = local.common_vrf
  l3out                     = local.l3out
  app_bds                   = var.app_bds
  app_single_bd             = local.app_single_bd
  app_subnet                = local.app_subnet
  app_epgs                  = var.app_epgs
  epg_external              = var.epg_external
  vds_name                  = var.vds_name
  web_to_order_contract     = var.web_to_order_contract
  order_to_payment_contract = var.order_to_payment_contract
  payment_to_store_contract = var.payment_to_store_contract
}




