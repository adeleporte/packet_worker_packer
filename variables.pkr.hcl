variable "photon_ovf_template" {
  type    = string
  default = "photon.xml.template"
}

variable "portgroup" {
  type    = string
  default = "DPortGroup7"
}

variable "vm_name" {
  type = string
}

variable "numvcpus" {
  type = number
}

variable "guest_username" {
  type = string
}

variable "guest_password" {
  type = string
}

variable "ramsize" {
  type = number
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "iso_checksum_type" {
  type = string
}

variable "version" {
  type = string
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_username" {
  type = string
}

variable "vcenter_password" {
  type = string
}

variable "datacenter" {
  type = string
}

variable "datastore" {
  type = string
}

variable "cluster" {
  type = string
}

variable "folder" {
  type = string
}

variable "network" {
  type = string
}