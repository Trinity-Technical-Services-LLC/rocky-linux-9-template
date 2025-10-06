# ============================================================================================= #
# - File: .\variables.pkr.hcl                                                 | Version: v1.0.0 #
# --- [ Description ] ------------------------------------------------------------------------- #
#                                                                                               #
# ============================================================================================= #

#region ------ [ Common Settings ] ------------------------------------------------------------ #

  // Removable Media Settings
  variable "common_iso_storage" {
    type        = string
    description = "The name of the source Proxmox storage location for ISO images. (e.g. 'local-lvm')"
  }

  // Where to store the completed VM template(s)
  variable "vm_storage_pool" {
    type        = string
    description = "The name of the Proxmox storage pool to store the VM template. (e.g. 'local-lvm')"
  }

  // Boot and Provisioning Settings
  variable "common_data_source" {
    type        = string
    description = "The provisioning data source. (e.g. 'http' or 'disk')"
  }

  variable "common_http_interface" {
    type        = string
    description = "Name of the network interface that Packer gets HTTPIP from. Defaults to the first non loopback interface."
    default     = null
  }

  variable "common_http_bind_address" {
    type        = string
    description = "Define an IP address on the host to use for the HTTP server."
    default     = null
  }

  variable "common_http_port_min" {
    type        = number
    description = "The start of the HTTP port range."
  }

  variable "common_http_port_max" {
    type        = number
    description = "The end of the HTTP port range."
  }

  variable "common_ip_wait_timeout" {
    type        = string
    description = "Time to wait for guest operating system IP address response."
  }

  variable "common_shutdown_timeout" {
    type        = string
    description = "Time to wait for guest operating system shutdown."
  }

  variable "common_hcp_packer_registry_enabled" {
    type        = bool
    description = "Enable the HCP Packer registry."
    default     = false
  }

#endregion --- [ Common Settings ] ------------------------------------------------------------ #


#region ------ [ Packer Settings ] ------------------------------------------------------------ #

  variable "deploy_user_name" {
    type        = string
    description = "The username to log in to the guest operating system. (e.g. 'ubuntu')"
    sensitive   = true
  }

  variable "deploy_user_password" {
    type        = string
    description = "The password to log in to the guest operating system."
    sensitive   = true
  }

  variable "deploy_user_key" {
    type        = string
    description = "The SSH public key to log in to the guest operating system."
    sensitive   = true
  }

#endregion --- [ Packer Settings ] ------------------------------------------------------------ #


#region ------ [ Proxmox Settings ] ----------------------------------------------------------- #

  #region ------ [ Proxmox Settings - Host Connection Settings ] ------------------------------ #

    // Proxmox Credentials
    variable "proxmox_api_token_id" {
      type        = string
      description = "The token to login to the Proxmox node/cluster. The format is USER@REALM!TOKENID. (e.g. packer@pam!packer_pve_token)"
      sensitive   = true
    }

    variable "proxmox_api_token_secret" {
      type        = string
      description = "The secret for the API token used to login to the Proxmox API."
      sensitive   = true
    }

    variable "proxmox_skip_tls_verify" {
      description = "true/false to skip Proxmox TLS certificate checks."
      type        = bool
      default     = false
      sensitive   = true
    }

    // Proxmox Specific Settings
    variable "proxmox_hostname" {
      type        = string
      description = "The FQDN or IP address of a Proxmox node. Only one node should be specified in a cluster."
      sensitive   = true
    }

    variable "proxmox_node" {
      type        = string
      description = "The name of the Proxmox node that Packer will build templates on."
      sensitive   = true
    }

  #endregion --- [ Proxmox Settings - Host Connection Settings ] ------------------------------ #

#endregion --- [ Proxmox Settings ] ----------------------------------------------------------- #


#region ------ [ Virtual Machine (VM) Settings ] ---------------------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Guest Operating System (OS) Settings ] ----- #

    variable "vm_os_type" {
      type        = string
      description = "The guest operating system type. (e.g. 'l26')"
    }

    variable "vm_cloudinit" {
      type        = bool
      description = "Enable or disable cloud-init drive in Proxmox. (e.g. false)"
      default     = false
    }

  #endregion --- [ Virtual Machine (VM) Settings - Guest Operating System (OS) Settings ] ----- #

  #region ------ [ Virtual Machine (VM) Settings - Hardware ] --------------------------------- #

    variable "vm_bios" {
      type        = string
      description = "The firmware type. Allowed values 'ovmf' or 'seabios'"
      default     = "ovmf"

      validation {
        condition     = contains(["ovmf", "seabios"], var.vm_bios)
        error_message = "The vm_bios value must be 'ovmf' or 'seabios'."
      }
    }

    variable "vm_bios_firmware_path" {
      type        = string
      description = "The firmware file to be used. Needed for EFI"
      default     = "/usr/share/ovmf/OVMF.fd"
    }

    variable "vm_cpu_count" {
      type        = number
      description = "The number of virtual CPUs. (e.g. '2')"
    }

    variable "vm_cpu_sockets" {
      type        = number
      description = "The number of virtual CPU sockets. (e.g. '1')"
    }

    variable "vm_cpu_type" {
      type        = string
      description = "The CPU type to emulate. See the Proxmox API documentation for the complete list of accepted values. For best performance, set this to host. Defaults to kvm64."
    }

    variable "vm_mem_size" {
      type        = number
      description = "The size for the virtual memory in MB. (e.g. '2048')"
    }

    variable "vm_disk_type" {
      type        = string
      description = "The type of disk to emulate. (e.g. 'virtio')"
    }

    variable "vm_disk_size" {
      type        = string
      description = "The size for the virtual disk in GB. (e.g. '32G')"
    }

    variable "vm_disk_format" {
      type        = string
      description = "The format of the file backing the disk. (e.g. 'qcow2')"
    }

    variable "vm_disk_controller_type" {
      type        = string
      description = "The SCSI controller model to emulate. (e.g. 'virtio-scsi-pci')"
    }

    variable "vm_network_card_model" {
      type        = string
      description = "The model of the virtual network adapter to emulate. (e.g. 'virtio')"
    }

  #endregion --- [ Virtual Machine (VM) Settings - Hardware ] --------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Boot Settings ] ---------------------------- #

    variable "vm_boot" {
      type        = string
      description = "The boot order for virtual machine devices. (e.g. 'order=virtio0;ide2;net0')"
    }

    variable "vm_boot_wait" {
      type        = string
      description = "The time to wait after booting the initial VM before typing the boot_command (e.g '10s')"
    }

  #endregion --- [ Virtual Machine (VM) Settings - Boot Settings ] ---------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Removal Media Settings ] ------------------- #

    variable "iso_path" {
      type        = string
      description = "The path on the source Proxmox storage location for ISO images. (e.g. 'iso')"
    }

    variable "iso_file" {
      type        = string
      description = "The file name of the ISO image used by the vendor. (e.g. 'ubuntu-<version>-live-server-amd64.iso')"
    }

    variable "iso_checksum" {
      type        = string
      description = "The checksum value of the ISO image provided by the vendor."
    }

  #endregion --- [ Virtual Machine (VM) Settings - Removal Media Settings ] ------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Metadata ] --------------------------------- #

    variable "vm_os_language" {
      type        = string
      description = "The guest operating system language."
      default     = "en_US"
    }

    variable "vm_os_keyboard" {
      type        = string
      description = "The guest operating system keyboard layout."
      default     = "us"
    }

    variable "vm_os_timezone" {
      type        = string
      description = "The guest operating system timezone."
      default     = "UTC"
    }

    variable "vm_os_family" {
      type        = string
      description = "The guest operating system family. Used for naming. (e.g. 'linux')"
    }

    variable "vm_os_name" {
      type        = string
      description = "The guest operating system name. Used for naming. (e.g. 'ubuntu')"
    }

    variable "vm_os_version" {
      type        = string
      description = "The guest operating system version. Used for naming. (e.g. '22-04-lts')"
    }

  #endregion --- [ Virtual Machine (VM) Settings - Metadata ] --------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Storage ] ---------------------------------- #

    variable "vm_efi_storage_pool" {
      type        = string
      description = "Set the UEFI disk storage location. (e.g. 'local-lvm')"
      default     = "local-lvm"
    }

    variable "vm_efi_type" {
      type        = string
      description = "Specifies the version of the OVMF firmware to be used. (e.g. '4m')"
      default     = "4m"
    }

    variable "vm_efi_pre_enrolled_keys" {
      type        = bool
      description = "Whether Microsoft Standard Secure Boot keys should be pre-loaded on the EFI disk. (e.g. false)"
      default     = false
    }

    variable "vm_disk_device" {
      type        = string
      description = "The device for the virtual disk. (e.g. 'sda')"
    }

    variable "vm_disk_use_swap" {
      type        = bool
      description = "Whether to use a swap partition."
    }

    variable "vm_disk_partitions" {
      type = list(object({
        name = string
        size = number
        format = object({
          label  = string
          fstype = string
        })
        mount = object({
          path    = string
          options = string
        })
        volume_group = string
      }))
      description = "The disk partitions for the virtual disk."
    }

    variable "vm_disk_lvm" {
      type = list(object({
        name    = string
        partitions = list(object({
          name = string
          size = number
          format = object({
            label  = string
            fstype = string
          })
          mount = object({
            path    = string
            options = string
          })
        }))
      }))
      description = "The LVM configuration for the virtual disk."
      default     = []
    }

  #endregion --- [ Virtual Machine (VM) Settings - Storage ] ---------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Networking ] ------------------------------- #

    variable "vm_bridge_interface" {
      type        = string
      description = "The name of the Proxmox bridge to attach the adapter to."
    }

    variable "vm_vlan_tag" {
      type        = string
      description = "If the adapter should tag packets, give the VLAN ID. (e.g. '102')"
    }

    variable "vm_ip_address" {
      type        = string
      description = "The IP address of the VM (e.g. 172.16.100.192)."
      default     = null
    }

    variable "vm_ip_netmask" {
      type        = number
      description = "The netmask of the VM (e.g. 24)."
      default     = null
    }

    variable "vm_ip_gateway" {
      type        = string
      description = "The gateway of the VM (e.g. 172.16.100.1)."
      default     = null
    }

    variable "vm_dns_list" {
      type        = list(string)
      description = "The nameservers of the VM."
      default     = []
    }

  #endregion --- [ Virtual Machine (VM) Settings - Networking ] ------------------------------- #

#endregion --- [ Virtual Machine (VM) Settings ] ---------------------------------------------- #

#region ------ [ Other Settings ] ------------------------------------------------------------- #

  variable "timeout" {
    description = "not sure why I need so high a timeout but here we are"
    default = "90m"
  }

  variable "additional_packages" {
    type        = list(string)
    description = "Additional packages to install."
    default     = []
  }

  variable "vm_network_device" {
    type        = string
    description = "The network device of the VM."
    default     = "ens192"
  }

#endregion --- [ Other Settings ] ------------------------------------------------------------- #
