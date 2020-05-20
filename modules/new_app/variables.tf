variable "tenant_name" {}
variable "app_bds" {
    type = map(object({
        ip = string
    }))
}
variable "app_epgs" {
    type = map(string)
}
variable epg_external {}
variable l3out {}
variable common_vrf {}
variable "vds_name" {}
variable "web_to_order_contract" {
    type = map(object({
    contract_name = string
    subject_name  = string
    filters = map(object({
        name    = string
        entries = list(map(string))
        })
    ) }))
    }
variable "order_to_payment_contract" {
    type = map(object({
    contract_name = string
    subject_name  = string
    filters = map(object({
        name    = string
        entries = list(map(string))
        })
    ) }))
    }
variable "payment_to_store_contract" {
    type = map(object({
    contract_name = string
    subject_name  = string
    filters = map(object({
        name    = string
        entries = list(map(string))
        })
    ) }))
    }