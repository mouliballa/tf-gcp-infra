data "google_storage_bucket_object" "bucket-mine" {
name   = "terraform/state/default.tfstate"
  bucket = "image-store-bucket-mine"
}
output "google_storage" {  
value       = data.google_storage_bucket_object.bucket-mine  
description = "The name of the gcp bucket"
} 

resource "google_storage_bucket" "work-space-example" {
  name     = "work-space-example-123"
location =  terraform.workspace == "default" ? "US" : "EU"
}
