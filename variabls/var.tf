variable "object_example_with_error" {
  description = "An example of a structural type in Terraform with an error"
  type        = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })

  default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = true
  }
}

variable "list_numeric_example" {  
description = "An example of a numeric list in Terraform"  
type        = list(number)  
default     = [1, 2, 3]
}


variable "server_port" { 
description = "The port the server will use for HTTP requests"  
type        = number
}

// need to passs the variable using terraform apply -var "server_port=8080"
// refrence can be done using var.server_port but if you using in shell scripts then please use ${..} 
// link --> https://www.terraform.io/docs/configuration/variables.html

// Terraform also allows you to define output variables by using the following syntax:
// you can take value as any resource and attribute like aws_lb.example.dns_name
output "public_port" {  
value       = var.server_port
description = "The public IP address of the web server"
}

