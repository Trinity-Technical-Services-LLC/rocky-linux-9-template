# ============================================================================================= #
# - File: .\locals.pkr.hcl                                                    | Version: v1.0.0 #
# --- [ Description ] ------------------------------------------------------------------------- #
#                                                                                               #
# ============================================================================================= #

locals {

  bios_boot_command = [
    "<up><wait>",
    "<tab><wait>",
    " text ${local.data_source_command}",
    "<enter><wait>"
  ]

  uefi_boot_command = [
    // This sends the "up arrow" key, typically used to navigate through boot menu options.
    "<up>",
    // This sends the "e" key. In the GRUB boot loader, this is used to edit the selected boot menu option.
    "e",
    // This sends two "down arrow" keys, followed by the "end" key, and then waits. This is used to navigate to a specific line in the boot menu option's configuration.
    "<down><down><end><wait>",
    // This types the string "text" followed by the value of the 'data_source_command' local variable.
    // This is used to modify the boot menu option's configuration to boot in text mode and specify the kickstart data source configured in the common variables.
    " text ${local.data_source_command}",
    // This sends the "enter" key, waits, turns on the left control key, sends the "x" key, and then turns off the left control key. This is used to save the changes and exit the boot menu option's configuration, and then continue the boot process.
    "<enter><wait><leftCtrlOn>x<leftCtrlOff>"
  ]

  build_by          = "Built by: HashiCorp Packer ${packer.version}"
  build_date        = formatdate("DD-MM-YYYY hh:mm ZZZ", "${timestamp()}" )
  build_version     = data.git-repository.cwd.head
  build_description = "Version: ${local.build_version}\nBuilt on: ${local.build_date}\n${local.build_by}\nCloud-Init: ${var.vm_cloudinit}"
  vm_disk_type      = var.vm_disk_type == "virtio" ? "vda" : "sda"
  manifest_date     = formatdate("YYYY-MM-DD hh:mm:ss", timestamp())
  manifest_path     = "${path.cwd}/manifests/"
  manifest_output   = "${local.manifest_path}${local.manifest_date}.json"
  data_source_content = {
    "/ks.cfg" = templatefile("${abspath(path.root)}/data/ks.pkrtpl.hcl", {
      deploy_user_name         = var.deploy_user_name
      deploy_user_password     = var.deploy_user_password
      deploy_user_key          = var.deploy_user_key
      vm_disk_type             = local.vm_disk_type
      vm_os_language           = var.vm_os_language
      vm_os_keyboard           = var.vm_os_keyboard
      vm_os_timezone           = var.vm_os_timezone
      vm_cloudinit             = var.vm_cloudinit
      network = templatefile("${abspath(path.root)}/data/network.pkrtpl.hcl", {
        device  = var.vm_bridge_interface
        ip      = var.vm_ip_address
        netmask = var.vm_ip_netmask
        gateway = var.vm_ip_gateway
        dns     = var.vm_dns_list
      })
      common_data_source       = var.common_data_source
      # lvm needs to be here so late commands can access vg names
      lvm                      = var.vm_disk_lvm
      storage                  = templatefile("${abspath(path.root)}/data/storage.pkrtpl.hcl", {
        device                 = var.vm_disk_device
        swap                   = var.vm_disk_use_swap
        partitions             = var.vm_disk_partitions
        lvm                    = var.vm_disk_lvm
        vm_bios                = var.vm_bios
      })
      additional_packages = join(" ", var.additional_packages)
    })
  }
  data_source_command = var.common_data_source == "http" ? "inst.ks=http://{{.HTTPIP}}:{{.HTTPPort}}/ks.cfg" : "inst.ks=/cdrom/ks.cfg"
  vm_name = "${var.vm_os_family}-${var.vm_os_name}-${var.vm_os_version}"
  boot_command = var.vm_bios == "ovmf" ? local.uefi_boot_command : local.bios_boot_command
  vm_bios = var.vm_bios == "ovmf" ? var.vm_bios_firmware_path : null
}
