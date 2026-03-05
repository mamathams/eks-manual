terraform {
  backend "s3" {
    bucket         = "eks-manual-tf-state-136191772987"
    key            = "eks-manual/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "eks-manual-terraform-locks"
    encrypt        = true
  }
}
