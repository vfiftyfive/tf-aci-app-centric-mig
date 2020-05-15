resource "aci_contract" "module_contract" {
  tenant_dn = var.tenant_id
  name      = var.filter_map.contract_object.contract_name
}

resource "aci_filter" "module_filter" {
  tenant_dn = var.tenant_id
  name      = var.filter_map.contract_object.filter.filter_object.name
}

resource "aci_contract_subject" "module_subject" {
  contract_dn                  = aci_contract.module_contract.id
  name                         = var.filter_map.contract_object.subject_name
  relation_vz_rs_subj_filt_att = [aci_filter.module_filter.name]
}

resource "aci_filter_entry" "all_module_filter_entries" {
  for_each    = var.filter_map.contract_object.filter
  filter_dn   = aci_filter.module_filter.id
  name        = each.value.name
  d_from_port = each.value.entry_1.d_from_port
  d_to_port   = each.value.entry_1.d_to_port
  ether_t     = each.value.entry_1.ether_t
  prot        = each.value.entry_1.prot
}

