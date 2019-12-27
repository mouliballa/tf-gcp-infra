***********BRIEF inro into TERRAFORM STATE***********

The state file format is a private API that changes with every release and is meant only for internal use withinTerraform. You should never edit the Terraform state files by hand or write code that reads them directly.If for some reason you need to manipulate the state file—which should be a relatively rare occurrence—usethe  terraform import or terraform state commands

If you’re using Terraform for a personal project, storing state in a single terraform.tfstate file that lives locally on your computer works just fine. But if you want to use Terraform as a team on a real product, you run into several problems:If you’re using Terraform for a personal project, storing state in a single terraform.tfstate file that lives locallyon your computer works just fine.But if you want to use Terraform as a team on a real product, you run into several problems:
Shared storage for state files -> Manual error,Locking,secrets
Locking state files
Isolating state files

//
Instead of using version control, the best way to manage shared storage for state files is to use Terraform’s built-insupport for remote backends. A Terraform backend determines how Terraform loads and stores state. The default backend, whichyou’ve been using this entire time, is the local backend, which stores the state file on your local disk. Remotebackends allow you to store the state file in a remote, shared store

Remote backends solve all three of the issues just listed:
Manual error
Locking
Secrets --> Most of the remote backends natively support encryption in transit and encryption at rest of the state file

you can use buckets --> aws s3 or gcp stroage
AWS s3 provides locking using synamo DB


To configure Terraform to store the state in your S3 bucket (withencryption and locking), you need to add a backend configuration to your Terraform code. 
This is configuration forTerraform itself, so it resides within a terraform block, and has the following syntax:
terraform { 
 backend "<BACKEND_NAME>"
 {    [CONFIG...]  
 }
 }
 
 terraform {
  backend "gcs" {
bucket  = "image-store-bucket-mine"
prefix  = "terraform/variables"
  }
}

Limitations with Terraform’s BackendsTerraform’s backends have a few limitations and gotchas that you need to be aware of. The first limitation is the chicken-and-eggsituation of using Terraform to create the S3 bucket where you want to store your Terraform state.
 To make this work,you had to use a two-step process:
 1) Write Terraform code to create the S3 bucket and DynamoDB table and deploy that code with a local backend.
 2) Go back to the Terraform code,  add a remote backend configuration to it to use the newly created S3 bucket andDynamoDB table, and run terraform init to copy your local state to S3.
 
 If you ever wanted to delete the S3 bucket and DynamoDB table, you’d have to do this two-step process in reverse:
 1) Go to the Terraform code, remove the backend configuration, and rerun terraform init to copy the Terraformstate back to your local disk.
 2) Run terraform destroy to delete the S3 bucket and DynamoDB table
 
 This two-step process is a bit awkward, but the good news is that you can share a single S3 bucket and DynamoDB tableacross all of your Terraform code, 
 so you’ll probably only need to do it once (or once per AWS account if you havemultiple accounts). 
 After the S3 bucket exists, in the rest of your Terraform code, you can specify the backendconfiguration right from the start without any extra steps.
 terraform {  
 backend "s3" {    
 bucket         = var.bucket    
 region         = var.region    
 dynamodb_table = var.dynamodb_table    
 key            = "example/terraform.tfstate"    
 encrypt        = true  
 }
 }
 
 ===********
 you could extract the repeated backend arguments,such as bucket and region, into a separate file called backend.hcl:
 # backend.hcl 
 bucket         = "terraform-up-and-running-state"
 region         = "us-east-2"
 dynamodb_table = "terraform-up-and-running-locks"
 encrypt        = true
 
 ===Only the key parameter remains in the Terraform code, since you still need to set a different key value for eachmodule:# Partial configuration. The other settings (e.g., bucket, region) will be# passed in from a file via -backend-config arguments to 'terraform init'
 terraform {  
 backend "s3"  {    
 key = "example/terraform.tfstate"  
 }
 }
 
 ==============*************
 To put all your partial configurations together, FIRST YOU NEED TO  run terraform init with the -backend-config argument:

$ terraform init -backend-config=backend.hcl


Isolating State Files
With a remote backend and locking, collaboration is no longer a problem. However, there is still one more problemremaining: isolation.When you first start using Terraform, you might be tempted to define all of your infrastructure in a single Terraformfile or a single set of Terraform files in one folder. The problem with this approach is 
that all of yourTerraform state is now stored in a single file, too, and a mistake anywhere could break everything.


For example, while trying to deploy a new version of your app in staging, you might break the app in production. Or,worse yet, you might corrupt your entire state file, either because you didn’t use locking or due to a rareTerraform bug, 
and now all of your infrastructure in all environments is broken

The whole point of having separate environments is that they are isolated from one another, so if you are managing allthe environments from a single set of Terraform configurations, you are breaking thatisolation.
There are two ways you could isolate state files:
1) Isolation via workspacesUseful for quick, isolated tests on the same configuration.
2)Isolation via file layoutUseful for production use cases for which you need strong separation between environments.

******Isolation via workspacesUseful for quick, isolated tests on the same configuration.******
Terraform workspaces allow you to store your Terraform state in multiple, separate, named workspaces. 
Terraformstarts with a single workspace called “default,

terraform workspace show --> to see current workspace name
terraform workspace list -->list all
terraform workspace new example1 --> create new workspace
terraform workspace select example1 --> select specific workspace

----******* see the bukcet for chnages --
it will create three state files for each work space
=====
This is handy when you already have a Terraform module deployed, and you want to do some experiments with it (e.g.,try to refactor the code), 
but you don’t want your experiments to affect the state of the already deployedinfrastructure. 
Terraform workspaces allow you to run terraform workspace new and deploy a new copy of the exactsame infrastructure, but storing the state in a separate file

In fact, you can even change how that module behaves based on the workspace you’re in by reading the workspace nameusing the expression terraform.workspace. For example, 
here’s how to set the Instance type to t2.medium inthe default workspace and t2.micro in all other workspaces (e.g., to save money when experimenting):
/*** example***
resource "aws_instance" "example" {  
ami           = "ami-0c55b159cbfafe1f0"  
instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}

Terraform workspaces can be a great way to quickly spin up and tear down different versions of your code, 
but they havea few drawbacks:
1) all of your workspace uses same bucket and use the same authentication and access controls for all the workspaces, which is one major reason workspacesare an unsuitable mechanism for isolating environments (e.g., isolating staging from production).

2) Workspaces are not visible in the code or on the terminal unless you run terraform workspace commands. Whenbrowsing the code, a module that has been deployed in one workspace looks exactly the same as a module deployed in10 workspaces. This makes maintenance more difficult, because you don’t have a good picture of your infrastructure.

3) Putting the two previous items together, the result is that workspaces can be fairly error prone. The lack ofvisibility makes it easy to forget what workspace you’re in and accidentally make changes in the wrong one
(e.g., accidentally running terraform destroy in a “production” workspace rather than a “staging” workspace)

To get proper isolation between environments, instead of workspaces, you’ll most likely want to use file layout,which is the topic of the next section. 


