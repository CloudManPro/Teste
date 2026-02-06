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

resource "cloudflare_workers_script" "Worker" {
  account_id                        = "bf9638139fc9b9a92fa0334ae15ac3ac"
  script_name                       = "Worker"
  compatibility_date                = "2026-02-05"
  compatibility_flags               = ["python_workers"]
  content                           = <<EOF
from js import Response

async def on_fetch(request, env):
    return Response.new("Hello World de Python no Cloudflare Workers!")

EOF
  content_type                      = "text/x-python"
  has_modules                       = true
  main_module                       = "index.py"
  usage_model                       = "bundled"
}


