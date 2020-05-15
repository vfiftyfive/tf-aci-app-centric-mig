variable "username" {}
variable "password" {}
variable "aci_private_key" {}
variable "aci_cert_name" {}
variable "apic_url" {}
variable "tenant_name" {}
variable "vrf" {}
variable "all_bds" {
  type = map(string)
}
variable "all_epgs" {
  type = map(string)
}
variable "vds_name" {}
variable "web_to_order_filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = map(object({
      name    = string
      entry_1 = map(string)
      })
  ) }))
}
variable "order_to_payment_filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = map(object({
      name    = string
      entry_1 = map(string)
      })
  ) }))
}
variable "payment_to_store_filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = map(object({
      name    = string
      entry_1 = map(string)
      })
  ) }))
}

