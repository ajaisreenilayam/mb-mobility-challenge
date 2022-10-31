output "client_secret" {
  value       = random_string.password.result
  description = "Client Secret"
}