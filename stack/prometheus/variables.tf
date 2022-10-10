variable "network_name" {
  description = "Network to attach to"
}
variable "multibox_container_names" {
  type = list
}
variable "multibox_container_metrics_port" {
  type = number
}