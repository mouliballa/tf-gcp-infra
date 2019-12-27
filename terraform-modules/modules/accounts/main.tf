
#service account creation is eventally consistent
resource "google_service_account" "service_account" {
 count = 3
  description = "terrafrom-service-account"
  account_id   = "${var.display_name}${count.index}"
  display_name = "${var.account_id}${count.index}"
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
} */
