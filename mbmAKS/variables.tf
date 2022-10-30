variable "location" {
  default = "westeurope"
}
variable "resource_group_name" {
  default = "mbm-rg-central-services"
}
variable "prefix" {
  default = "mbm"
}
variable "availability_zones" {
  type        = list(string)
  description = "AKS Availability Zones"
  default     = ["1", "2"]
}