locals {
    bd_ip = [ for bd in var.app_bds: bd.ip ]
    subnet_list = concat(local.bd_ip, list(var.app_subnet))
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

resource "aci_tenant" "mig_app_centric" {
    name = var.tenant_name
}

resource "aci_application_profile" "new_app" {
    tenant_dn = aci_tenant.mig_app_centric.id
    name      = "new_app"
}

data "aci_vrf" "common_vrf" {
    tenant_dn = data.aci_tenant.common_tenant.id
    name      = var.common_vrf
}

resource "aci_bridge_domain" "app_single_bd" {
    tenant_dn          = aci_tenant.mig_app_centric.id
    name               = var.app_single_bd
    relation_fv_rs_ctx = data.aci_vrf.common_vrf.name
}

resource "aci_subnet" "app_subnets" {
    for_each         = toset(local.subnet_list)
    bridge_domain_dn = aci_bridge_domain.app_single_bd.id
    ip               = each.key
}

resource "aci_application_epg" "app_epgs" {
    application_profile_dn = aci_application_profile.new_app.id
    for_each               = var.app_epgs
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

resource aci_rest "relation_ctrct_to_ext_epg" {
    path       = "/api/node/mo/uni/tn-common/out-${var.l3out}/instP-${var.epg_external}/rscons-${module.web_to_order.contract_name}.json"
    class_name = "fvRsCons"
    content = {
        tnVzBrCPName = module.web_to_order.contract_name
    }
}

data "aci_vmm_domain" "vmware_vds" {
    provider_profile_dn = "uni/vmmp-VMware"
    name                = var.vds_name
}

module "web_to_order" {
    source = "../contract"

    anp       = aci_application_profile.new_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.web_to_order_contract
}

module "payment_to_store" {
    source = "../contract"

    anp       = aci_application_profile.new_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.payment_to_store_contract
}

module "order_to_payment" {
    source = "../contract"

    anp       = aci_application_profile.new_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.order_to_payment_contract
    }
