
provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}


#service account creation is eventally consistent
resource "google_service_account" "service_account" {
 count = 3
  description = "terrafrom-service-account"
  account_id   = "serviceaccountid${count.index}"
  display_name = "Service Account${count.index}"
  project     = "gce-challange"
#  email      = "test@test.com"
}

output "sadetails" {
  value = "${google_service_account.service_account[2].email}"
}
/*  name = "${google_service_account.service_account.name}"
 unique_id = "${google_service_account.service_account.unique_id}"
 wsaid = "${google_service_account.service_account.id}"
} */
