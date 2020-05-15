username        = "api_user"
aci_private_key = "api_user.pem"
aci_cert_name   = "api_user_cert"
tenant_name     = "mytenant"
vrf             = "PROD_VRF"
all_bds = {
  bd_order   = "bd_order"
  bd_payment = "bd_payment"
  bd_store   = "bd_store"
}
all_epgs = {
  epg_order   = "bd_order"
  epg_payment = "bd_payment"
  epg_store   = "bd_store"
}
vds_name = "vc05-Fabric2-VDS01"
web_to_order_filter_map = {
  contract_object = {
    contract_name = "web_to_order"
    subject_name  = "web_to_order_subject"
    filter = {
      filter_object = {
        name = "web_to_order_https_filter"
        entry_1 = {
          d_from_port = "443"
          d_to_port   = "443"
          ether_t     = "ip"
          prot        = "tcp"
        }
      }
    }
  }
}
order_to_payment_filter_map = {
  contract_object = {
    contract_name = "order_to_payment"
    subject_name  = "order_to_payment_subject"
    filter = {
      filter_object = {
        name = "order_to_payment_https_filter"
        entry_1 = {
          d_from_port = "443"
          d_to_port   = "443"
          ether_t     = "ip"
          prot        = "tcp"
        }
      }
    }
  }
}
payment_to_store_filter_map = {
  contract_object = {
    contract_name = "payment_to_store"
    subject_name  = "payment_to_store_subject"
    filter = {
      filter_object = {
        name = "payment_to_store_mongodb_filter"
        entry_1 = {
          d_from_port = "27017"
          d_to_port   = "27017"
          ether_t     = "ip"
          prot        = "tcp"
        }
      }
    }
  }
}