username        = "api_user"
aci_private_key = "api_user.pem"
aci_cert_name   = "api_user_cert"
app_bds = {
  bd_order = {
    ip = "192.168.10.1/24"
  }
  bd_payment = {
    ip = "192.168.11.1/24"
  }
  bd_store = {
    ip = "192.168.12.1/24"
  }
}
app_epgs = {
  epg_order   = "bd_order"
  epg_payment = "bd_payment"
  epg_store   = "bd_store"
}
epg_external = "defaultInstP"
vds_name     = "vc05-Fabric2-VDS01"
web_to_order_contract = {
  contract_object = {
    contract_name = "web_to_order"
    subject_name  = "web_to_order_subject"
    filters = {
      filter_1 = {
        name = "web_to_order_https_filter"
        entries = [{
          d_from_port = "443"
          d_to_port   = "443"
          ether_t     = "ip"
          prot        = "tcp"
        }]
      }
    }
  }
}
order_to_payment_contract = {
  contract_object = {
    contract_name = "order_to_payment"
    subject_name  = "order_to_payment_subject"
    filters = {
      filter_1 = {
        name = "order_to_payment_https_filter"
        entries = [{
          d_from_port = "443"
          d_to_port   = "443"
          ether_t     = "ip"
          prot        = "tcp"
        }]
      }
    }
  }
}
payment_to_store_contract = {
  contract_object = {
    contract_name = "payment_to_store"
    subject_name  = "payment_to_store_subject"
    filters = {
      filter_1 = {
        name = "payment_to_store_mongodb_filter"
        entries = [{
          d_from_port = "27017"
          d_to_port   = "27017"
          ether_t     = "ip"
          prot        = "tcp"
        }]
      }
    }
  }
}
vsphere_user            = "administrator@vsphere.local"
vsphere_server          = "nvermand-vc-05.uktme.cisco.com"
vsphere_datacenter      = "uktme-01"
vsphere_compute_cluster = "nv-cl01"
vsphere_template        = "test-vm"
vsphere_datastore       = "vsanDatastore-cl01"
vm_prefix               = "devnet-vm-"
vcpu                    = "2"
memory                  = "1024"
folder                  = "ACI"
domain_name             = "uktme.cisco.com"
vm_cidr                 = "192.168.14.0/24"
gateway                 = "192.168.14.1"
dns_domain              = "uktme.cisco.com"
dns_search              = ["uktme.cisco.com"]
dns_list                = ["10.237.97.134", "10.237.97.135"]
vm_ip_address_start     = "10"