
/* . Each Terraform provider exposes a variety of data sources. For example, the AWS providerincludes data sources to look up VPC data, subnet data, AMI IDs, IP address ranges, the current user’s identity, andmuch more.
data "<PROVIDER>_<TYPE>" "<NAME>" { 
[CONFIG ...]
} */


data "google_compute_network" "default" { 
// default = true
  name = "default"
}

// refrence the data data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>
output "network_name" {
value = data.google_compute_network.default.subnetworks_self_links
}


/*
You can combine this with another data source, aws_subnet_ids, to look up the subnets within that VPC:
data "aws_subnet_ids" "default" {  
vpc_id = data.aws_vpc.default.id
} */
