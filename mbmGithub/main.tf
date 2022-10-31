data "github_actions_public_key" "example_public_key" {
  repository = "mb-mobility-challenge"
}

resource "github_actions_secret" "example_secret" {
  repository       = "mb-mobility-challenge"
  secret_name      = "example_secret_name"
  plaintext_value  = var.some_secret_string
}

