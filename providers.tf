#provider "aws" {
#  profile = var.profile
#  region  = var.region
#}

provider "aws" {
  alias      = "plain_text_access_keys_provider"
  region     = "us-west-2"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

