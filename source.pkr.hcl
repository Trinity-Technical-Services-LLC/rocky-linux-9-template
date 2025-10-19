# ============================================================================================= #
# - File: .\sources.pkr.hcl                                                   | Version: v1.0.0 #
# --- [ Description ] ------------------------------------------------------------------------- #
#                                                                                               #
# ============================================================================================= #

source "proxmox-iso" "linux-rocky" {

  // Proxmox Connection Settings and Credentials
  proxmox_url              = "https://${secrets.PROXMOX_HOSTNAME}:8006/api2/json"
  username                 = "${var.PROXMOX_TOKEN_ID}"
  token                    = "${var.PROXMOX_TOKEN_SECRET}"
  insecure_skip_tls_verify = "${var.INSECURE_SKIP_TLS_VERIFY}"

  // Proxmox Settings
  node                     = "${secrets.PROXMOX_HOSTNAME}"

  // Virtual Machine Settings
  vm_name         = "${local.vm_name}"
  bios            = "${var.vm_bios}"
  sockets         = "${var.vm_cpu_sockets}"
  cores           = "${var.vm_cpu_count}"
  cpu_type        = "${var.vm_cpu_type}"
  memory          = "${var.vm_mem_size}"
  os              = "${var.vm_os_type}"
  scsi_controller = "${var.vm_disk_controller_type}"

  disks {
    disk_size     = "${var.vm_disk_size}"
    type          = "${var.vm_disk_type}"
    storage_pool  = "${var.vm_storage_pool}"
    format        = "${var.vm_disk_format}"
  }

  dynamic "efi_config" {
    for_each = var.vm_bios == "ovmf" ? [1] : []
    content {
      efi_storage_pool  = var.vm_bios == "ovmf" ? var.vm_efi_storage_pool : null
      efi_type          = var.vm_bios == "ovmf" ? var.vm_efi_type : null
      pre_enrolled_keys = var.vm_bios == "ovmf" ? var.vm_efi_pre_enrolled_keys : null
    }
  }

  ssh_username    = "${var.deploy_user_name}"
  ssh_password    = "${var.deploy_user_password}"
  ssh_timeout     = "${var.timeout}"
  ssh_port        = "22"
  qemu_agent      = true

  network_adapters {
    bridge     = "${var.vm_bridge_interface}"
    model      = "${var.vm_network_card_model}"
    vlan_tag   = "${var.vm_vlan_tag}"
  }

  // Removable Media Settings
  http_content = "${var.common_data_source}" == "http" ? "${local.data_source_content}" : null

  // Boot and Provisioning Settings
  http_interface    = var.common_data_source == "http" ? var.common_http_interface : null
  http_bind_address = var.common_data_source == "http" ? var.common_http_bind_address : null
  http_port_min     = var.common_data_source == "http" ? var.common_http_port_min : null
  http_port_max     = var.common_data_source == "http" ? var.common_http_port_max : null
  boot              = var.vm_boot
  boot_wait         = var.vm_boot_wait
  boot_command      = local.boot_command

  boot_iso {
    iso_file      = "${var.iso_path}/${var.iso_file}"
    unmount       = true
    iso_checksum  = "${var.iso_checksum}"
  }

  dynamic "additional_iso_files" {
    for_each = var.common_data_source == "disk" ? [1] : []
    content {
      cd_files = var.common_data_source == "disk" ? local.data_source_content : null
      cd_label = var.common_data_source == "disk" ? "cidata" : null
      iso_storage_pool = var.common_data_source == "disk" ? "local" : null
    }
  }

  template_name        = "${local.vm_name}"
  template_description = "${local.build_description}"

  # VM Cloud Init Settings
  cloud_init              = var.vm_cloudinit
  cloud_init_storage_pool = var.vm_cloudinit == true ? var.vm_storage_pool : null

}
