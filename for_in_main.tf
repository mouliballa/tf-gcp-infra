


provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}

variable "names" {
  description = "A list of names"
  type        = list(string)
  default     = ["neo", "trinity", "morpheus"]
}

output "upper_names" {
  value = [for name in var.names : upper(name)]
}
