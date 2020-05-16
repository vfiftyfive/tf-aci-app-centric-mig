variable tenant_id {}
variable "contract" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filter = map(object({
      name    = string
      entry_1 = map(string)
    })
  )}))
}
variable "anp" {}
