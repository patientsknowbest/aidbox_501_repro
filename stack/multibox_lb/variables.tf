variable "network_name" {
  description = "Network to attach to"
}
variable "multibox_container_names" {
  description = "list of containers running multibox"
  type = list
}
variable "multibox_container_port" {
  description = "port running multibox server on containers"
  type = number
}