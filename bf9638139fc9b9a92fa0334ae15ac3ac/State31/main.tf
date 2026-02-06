terraform {
  required_version = ">= 1.0.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
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

### CATEGORY: MISC ###

resource "cloudflare_r2_bucket" "minha-bucket-teste-cloudman" {
  account_id                        = "bf9638139fc9b9a92fa0334ae15ac3ac"
  name                              = "minha-bucket-teste-cloudman"
}

resource "cloudflare_workers_script" "worker1" {
  account_id          = "bf9638139fc9b9a92fa0334ae15ac3ac"
  script_name                = "worker1"  # Note: Na v5 do provider, 'script_name' mudou para 'name'
  compatibility_date  = "2024-10-21" # Use uma data estável e recente
  
  # CORREÇÃO AQUI: Remova "javascript" e adicione "python_workers"
  compatibility_flags = ["python_workers"] 

  content             = ""

  content_type        = "text/x-python"
  usage_model         = "bundled"
}



