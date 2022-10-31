output "client_secret" {
  value       = random_string.password.result
  description = "Client Secret"
}
output "azuread_service_principal_secret" {
  value = azuread_service_principal.auth.id
}