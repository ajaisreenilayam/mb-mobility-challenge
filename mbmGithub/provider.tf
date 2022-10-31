terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.7.0"
    }
  }
}

provider "github" {
  # Configuration options
}
