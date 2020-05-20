#Deploys a Network Centric app, ie: 3 EPGs mapped to 3 different BD with contracts applied
locals {
  tenant_name   = "mytenant"
  common_vrf    = "default"
  l3out         = "default"
}



provider "aci" {
  username = var.username
  # private_key = var.aci_private_key
  # cert_name   = var.aci_cert_name
  password = var.password
  url      = var.apic_url
  insecure = true
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





