# provider 설정
provider "aws" {
  region = var.region
  shared_credentials_files = ["$HOME/.aws/credentials"]
  profile = "default"
}