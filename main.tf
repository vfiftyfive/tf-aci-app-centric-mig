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

resource "aci_vrf" "prod_vrf" {
  tenant_dn = aci_tenant.mig_app_centric.id
  name      = var.vrf
}

resource "aci_bridge_domain" "all_bds" {
  tenant_dn          = aci_tenant.mig_app_centric.id
  for_each           = var.all_bds
  name               = each.value
  relation_fv_rs_ctx = aci_vrf.prod_vrf.name
}

resource "aci_application_epg" "all_epgs" {
  application_profile_dn = aci_application_profile.old_app.id
  for_each               = var.all_epgs
  name                   = each.key
  relation_fv_rs_bd      = each.value
  relation_fv_rs_dom_att = [data.aci_vmm_domain.vmware_vds.id]
}

data "aci_vmm_domain" "vmware_vds" {
  provider_profile_dn = "uni/vmmp-VMware"
  name                = var.vds_name
}

module "web_to_order_contract" {
  source = "./modules/create_contract"

  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.web_to_order_filter_map
}

module "order_to_payment_contract" {
  source = "./modules/create_contract"

  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.order_to_payment_filter_map
}

module "payment_to_store_contract" {
  source = "/home/nvermand/lab_share/nvermand/terraform/modules/create_contract"

  tenant_id  = aci_tenant.mig_app_centric.id
  filter_map = var.payment_to_store_filter_map
}
