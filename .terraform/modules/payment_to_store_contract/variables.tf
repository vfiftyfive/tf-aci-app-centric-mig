variable tenant_id {}
variable "filter_map" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = map(object({
      name    = string
      entry_1 = map(string)
    })
  )}))
}
