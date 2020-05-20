locals {
    bd_list = keys(var.app_bds)
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

data "aci_tenant" "mig_app_centric" {
    name = var.tenant_name
}

resource "aci_application_profile" "old_app" {
    tenant_dn = data.aci_tenant.mig_app_centric.id
    name      = "old_app"
}

data "aci_vrf" "common_vrf" {
    tenant_dn = data.aci_tenant.common_tenant.id
    name      = var.common_vrf
}

resource "aci_bridge_domain" "app_bds" {
    for_each           = var.app_bds
    tenant_dn          = data.aci_tenant.mig_app_centric.id
    name               = each.key
    relation_fv_rs_ctx = data.aci_vrf.common_vrf.name
}

resource "aci_subnet" "app_subnets" {
    for_each         = var.app_bds
    bridge_domain_dn = element([for bd in local.bd_list : aci_bridge_domain.app_bds[bd].id if each.key == bd], 1)
    ip               = each.value.ip
}

resource "aci_application_epg" "app_epgs" {
    application_profile_dn = aci_application_profile.old_app.id
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
    path       = "/api/node/mo/uni/tn-${var.common_vrf}/out-${var.l3out}/instP-${var.epg_external}.json"
    class_name = "fvRsCons"
    content = {
    tDn = "uni/tn-${var.common_vrf}/brc-${module.web_to_order.contract_name}"
    }
}

data "aci_vmm_domain" "vmware_vds" {
    provider_profile_dn = "uni/vmmp-VMware"
    name                = var.vds_name
}

module "web_to_order" {
    source = "../contract"

    anp       = aci_application_profile.old_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.web_to_order_contract
}

module "payment_to_store" {
    source = "../contract"

    anp       = aci_application_profile.old_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.payment_to_store_contract
}

module "order_to_payment" {
    source = "../contract"

    anp       = aci_application_profile.old_app.id
    tenant_id = data.aci_tenant.common_tenant.id
    contract  = var.order_to_payment_contract
    }
