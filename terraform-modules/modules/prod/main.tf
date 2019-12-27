module "service_accounts" {  
    source = "../modules/accounts"

    display_name           = "prod-account"  
    account_id = "module-prod"  
    }

/* just an example to show how module outputs can be accessed in different environment resource block
resource "google_storage_bucket" "work-space-example" {
  name     = "module.service_accounts.sadetails"
location =  terraform.workspace == "default" ? "US" : "EU"
}

 */
