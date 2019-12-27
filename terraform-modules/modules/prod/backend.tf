
provider "google" {
project = "gce-challange"
 // region  = "us-centra11"
  zone    = "us-central1-a"
}


terraform {
  backend "gcs" {
//bucket  = "image-store-bucket-mine"
prefix  = "terraform/modules-example/prod"
  }
}
