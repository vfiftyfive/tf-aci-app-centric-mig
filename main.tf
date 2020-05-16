#Deploys a Network Centric app, ie: 3 EPGs mapped to 3 different BD with contracts applied

locals {
  bd_list = keys(var.all_bds)
  epg_list = {
    epg_order = {
      name      = "epg_order"
      providers = [module.web_to_order.contract_name]
      consumers = [module.order_to_payment.contract_name]
    }
    epg_payment = {
      name      = "epg_payment"
      providers = [module.order_to_payment.contract_name]
      consumers = [module.payment_to_store.contract_name]
    }
    epg_store = {
      name      = "epg_store"
      providers = [module.payment_to_store.contract_name]
      consumers = [""]
    }
  }
}

provider "aci" {
  username = var.username
  # private_key = var.aci_private_key
  # cert_name   = var.aci_cert_name
  password = var.password
  url      = var.apic_url
  insecure = true
}

resource "aci_application_profile" "old_app" {
  tenant_dn = aci_tenant.mig_app_centric.id
  name      = "old_app"
}

resource "aci_tenant" "mig_app_centric" {
  name = var.tenant_name
}

data "aci_vrf" "common_vrf" {
  tenant_dn = data.aci_tenant.common_tenant.id
  name      = var.common_vrf
}

resource "aci_bridge_domain" "all_bds" {
  for_each           = var.all_bds
  tenant_dn          = aci_tenant.mig_app_centric.id
  name               = each.key
  relation_fv_rs_ctx = data.aci_vrf.common_vrf.name
}

resource "aci_subnet" "all_subnets" {
  for_each         = var.all_bds
  bridge_domain_dn = element([for bd in local.bd_list : aci_bridge_domain.all_bds[bd].id if each.key == bd], 1)
  ip               = each.value.ip
}

resource "aci_application_epg" "all_epgs" {
  application_profile_dn = aci_application_profile.old_app.id
  for_each               = var.all_epgs
  name                   = each.key
  relation_fv_rs_bd      = each.value
  relation_fv_rs_dom_att = [data.aci_vmm_domain.vmware_vds.id]
  relation_fv_rs_prov    = [for epg in local.epg_list : join(",", epg.providers) if each.key == epg.name]
  relation_fv_rs_cons    = [for epg in local.epg_list : join(",", epg.consumers) if each.key == epg.name]
}

data "aci_tenant" "common_tenant" {
  name = "common"
}

data "aci_l3_outside" "l3out" {
  tenant_dn = data.aci_tenant.common_tenant.id
  name      = var.l3out
}

resource "aci_external_network_instance_profile" "default-ext-epg" {
  l3_outside_dn = data.aci_l3_outside.l3out.id
  name          = var.epg_external
  relation_fv_rs_cons = [ module.web_to_order.contract_name ]
}

data "aci_vmm_domain" "vmware_vds" {
  provider_profile_dn = "uni/vmmp-VMware"
  name                = var.vds_name
}

module "web_to_order" {
  source = "./modules/create_contract"

  anp       = aci_application_profile.old_app.id
  tenant_id = data.aci_tenant.common_tenant.id
  contract  = var.web_to_order_contract
}

module "payment_to_store" {
  source = "./modules/create_contract"

  anp       = aci_application_profile.old_app.id
  tenant_id = data.aci_tenant.common_tenant.id
  contract  = var.payment_to_store_contract
}

module "order_to_payment" {
  source = "./modules/create_contract"

  anp       = aci_application_profile.old_app.id
  tenant_id = data.aci_tenant.common_tenant.id
  contract  = var.order_to_payment_contract
}
