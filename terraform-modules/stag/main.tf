module "service_accounts" {  
    source = "../modules/accounts"

    display_name  = "stag-account"  
    account_id = "stag-prod"  
    }


/* just an example to show how module outputs can be accessed in different environment resource block"
    resource "google_storage_bucket" "work-space-example" {
  name     = "${module.service_accounts.sadetails}"
location =  terraform.workspace == "default" ? "US" : "EU"
} */

// working example to show how module outputs can be accessed in different environment resource block
output "sadetails" {  
value = module.service_accounts.sadetails
description = "The email of the Auto Scaling Group"
}