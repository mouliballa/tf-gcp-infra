provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}

# userslist 
variable "user_names" {
  description = "Create service-account with these names"
  type        = list(string)
  default     = ["test", "serviceuser", "created"]
}


#service account creation is eventally consistent
resource "google_service_account" "service_account" {
   for_each = toset(var.user_names)
#  count = length(var.user_names)
  description = "terrafrom-service-account"
  account_id   = each.value #"${lower(element(var.user_names, count.index))}" #${var.user_names[count.index]}"
  display_name = "test"  #"var.user_names[count.index]"
  project     = "gce-challange"
#  email      = "test@test.com"
}

/*
output "sadetails" {
  value = "${google_service_account.service_account[2].email}"
}
  name = "${google_service_account.service_account.name}"
 unique_id = "${google_service_account.service_account.unique_id}"
 wsaid = "${google_service_account.service_account.id}"
*/
