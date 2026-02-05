terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0" # Alterado de ~> 4.0 para ~> 5.0
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
  api_token = "RdLPk_KAWm8WN7aczL3hpY9GdBOrtp7Q_xJZ6pr-" 
}



resource "cloudflare_r2_bucket" "minha-bucket-teste-cloudman" {
  # Tente acessar via .result se estiver na v5, ou verifique se accounts existe
  account_id = "bf9638139fc9b9a92fa0334ae15ac3ac"
  name       = "minha-bucket-teste-cloudman"
}



