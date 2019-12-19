

provider "google" {
project = "gce-challange"
  region  = "us-centra11"
  zone    = "us-central1-a"
}

variable "hero_thousand_faces" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}

output "bios" {
  value = [for name, role in var.hero_thousand_faces : "${name} is the ${role}"]
}

variable "hero_thousand" {
  description = "map"
  type        = map(string)
  default     = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}

output "upper_roles" {  
value = {for name, role in var.hero_thousand : upper(name) => upper(role)}
}

#Loops with the for String Directive %{ for <ITEM> in <COLLECTION> }<BODY>%{ endfor }

variable "names" {
  description = "Names to render"
  type        = list(string) 
  default     = ["neo", "trinity", "morpheus"]
}

output "for_directive" {  
value = <<EOF
%{ for name in var.names }  
${name}
%{ endfor }
EOF
}

output "for_directive_strip_marker" {  
value = <<EOF 
%{~ for name in var.names }
${name}
%{~ endfor }
EOF
}
