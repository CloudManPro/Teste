terraform {
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "bucket-teste-backend-terraform"
    key            = "bf9638139fc9b9a92fa0334ae15ac3ac/State31/main.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TableBE"
    encrypt        = true
  }
}

# --- Main Cloud Provider ---
provider "cloudflare" {
}

data "cloudflare_accounts" "mine" {}

### CATEGORY: MISC ###

resource "cloudflare_r2_bucket" "asd" {
  account_id                        = "${data.cloudflare_accounts.mine.accounts[0].id}"
  name                              = "asd"
  storage_class                     = "Standard"
}


