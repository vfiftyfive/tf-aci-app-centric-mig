resource "aci_contract" "mod_contract" {
  tenant_dn = var.tenant_id
  name      = var.contract.contract_object.contract_name
}

resource "aci_filter" "mod_filter" {
  tenant_dn = var.tenant_id
  name      = var.contract.contract_object.filters.filter_1.name
}

resource "aci_contract_subject" "mod_subject" {
  contract_dn                  = aci_contract.mod_contract.id
  name                         = var.contract.contract_object.subject_name
  relation_vz_rs_subj_filt_att = [aci_filter.mod_filter.name]
}

resource "aci_filter_entry" "mod_filter_entry" {
  for_each    = var.contract.contract_object.filters
  filter_dn   = aci_filter.mod_filter.id
  name        = each.value.name
  d_from_port = each.value.entries[0].d_from_port
  d_to_port   = each.value.entries[0].d_to_port
  ether_t     = each.value.entries[0].ether_t
  prot        = each.value.entries[0].prot
}

output "contract_name" {
  value = aci_contract.mod_contract.name
}
