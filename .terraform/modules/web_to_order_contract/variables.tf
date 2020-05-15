variable tenant_id {}
variable "web_to_order_filter" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = object({
      name    = string
      entries = map(string)
    })
  }))
}
variable "order_to_payment_filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = object({
      name    = string
      entries = map(string)
    })
  }))
}
variable "payment_to_store_filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = object({
      name    = string
      entries = map(string)
    })
  }))
}