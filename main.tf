#Deploys a Network Centric app, ie: 3 EPGs mapped to 3 different BD with contracts applied

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
  tenant_dn          = aci_tenant.mig_app_centric.id
  for_each           = var.all_bds
  name               = each.value
  relation_fv_rs_ctx = data.aci_vrf.common_vrf.name
}

resource "aci_application_epg" "all_epgs" {
  application_profile_dn = aci_application_profile.old_app.id
  for_each               = var.all_epgs
  name                   = each.key
  relation_fv_rs_bd      = each.value
  relation_fv_rs_dom_att = [data.aci_vmm_domain.vmware_vds.id]
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
}

data "aci_vmm_domain" "vmware_vds" {
  provider_profile_dn = "uni/vmmp-VMware"
  name                = var.vds_name
}

module "web_to_order_contract" {
  source = "./modules/create_contract"

  # providers = []
  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.web_to_order_filter_map
}

module "payment_to_store_contract" {
  source = "./modules/create_contract"

  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.payment_to_store_filter_map
}

module "order_to_payment_contract" {
  source = "./modules/create_contract"

  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.order_to_payment_filter_map
}
