variable tenant_id {}
variable "contract" {
  type = map(object({
    contract_name = string
    subject_name  = string
    filters = map(object({
      name    = string
      entries = list(map(string))
    })
  )}))
}
variable "anp" {}
