terraform {
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      # 1. Alterado para permitir a versão 5
      version = "~> 5.0" 
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

resource "cloudflare_r2_bucket" "minha-bucket-teste-cloudman" {
  # 2. Na v5, o atributo mudou de 'accounts' para 'result'
  # Também removi as aspas e o ${} que não são mais necessários em versões modernas do Terraform
  account_id = data.cloudflare_accounts.mine.result[0].id
  name       = "minha-bucket-teste-cloudman"
}