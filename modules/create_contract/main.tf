resource "aci_contract" "_" {
  tenant_dn = var.tenant_id
  name      = var.contract.contract_object.contract_name
}

resource "aci_filter" "_" {
  tenant_dn = var.tenant_id
  name      = var.contract.contract_object.filter.filter_object.name
}

resource "aci_contract_subject" "_" {
  contract_dn                  = aci_contract._.id
  name                         = var.contract.contract_object.subject_name
  relation_vz_rs_subj_filt_att = [aci_filter._.name]
}

resource "aci_filter_entry" "_" {
  for_each    = var.contract.contract_object.filter
  filter_dn   = aci_filter._.id
  name        = each.value.name
  d_from_port = each.value.entry_1.d_from_port
  d_to_port   = each.value.entry_1.d_to_port
  ether_t     = each.value.entry_1.ether_t
  prot        = each.value.entry_1.prot
}

output "contract_name" {
  value = aci_contract._.name
}
