# ============================================================================================= #
# - File: .\variables.pkvars.hcl                                              | Version: v1.0.0 #
# --- [ Description ] ------------------------------------------------------------------------- #
#                                                                                               #
# ============================================================================================= #


#region ------ [ Common Settings ] ------------------------------------------------------------ #

  // Removable Media Settings
  common_iso_storage = "OS"

  // Where to store the completed VM templates
  vm_storage_pool = "nvme-pool"

  // Boot and Provisioning Settings
  common_data_source       = "http"
  common_http_interface    = null
  common_http_bind_address = null
  common_http_port_min     = 8000
  common_http_port_max     = 8099
  common_ip_wait_timeout   = "20m"
  common_shutdown_timeout  = "15m"

  // HCP Packer
  common_hcp_packer_registry_enabled = false

#endregion --- [ Common Settings ] ------------------------------------------------------------ #


#region ------ [ Packer Settings ] ------------------------------------------------------------ #

  # deploy_user_name     = ""
  # deploy_user_password = ""
  # deploy_user_key      = ""

#endregion --- [ Packer Settings ] ------------------------------------------------------------ #


#region ------ [ Proxmox Settings ] ----------------------------------------------------------- #

  #region ------ [ Proxmox Settings - Host Connection Settings ] ------------------------------ #

    // Proxmox Credentials
    #proxmox_api_token_id     = <!Note: Set via GitHub Actions & Secrets>
    #proxmox_api_token_secret = <!Note: Set via GitHub Actions & Secrets>
    #proxmox_skip_tls_verify  = <!Note: Set via GitHub Actions & Secrets>

    // Proxmox Specific Settings
    #proxmox_hostname = <!Note: Set via GitHub Actions & Secrets>
    #proxmox_node     = <!Note: Set via GitHub Actions & Secrets>

  #endregion --- [ Proxmox Settings - Host Connection Settings ] ------------------------------ #

#endregion --- [ Proxmox Settings ] ----------------------------------------------------------- #


#region ------ [ Virtual Machine (VM) Settings ] ---------------------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Guest Operating System (OS) Settings ] ----- #

    vm_os_type       = "l26"
    vm_cloudinit     = true

  #endregion --- [ Virtual Machine (VM) Settings - Guest Operating System (OS) Settings ] ----- #

  #region ------ [ Virtual Machine (VM) Settings - Hardware ] --------------------------------- #

    vm_bios                 = "ovmf"
    vm_bios_firmware_path   = "./OVMF.fd"
    vm_cpu_count            = 1
    vm_cpu_sockets          = 1
    vm_cpu_type             = "host"
    vm_mem_size             = 2048
    vm_disk_type            = "virtio"
    vm_disk_size            = "32G"
    vm_disk_format          = "raw"
    vm_disk_controller_type = "virtio-scsi-pci"
    vm_network_card_model   = "virtio"

  #endregion --- [ Virtual Machine (VM) Settings - Hardware ] --------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Boot Settings ] ---------------------------- #

    vm_boot      = "order=virtio0;ide2;net0"
    vm_boot_wait = "10s"

  #endregion --- [ Virtual Machine (VM) Settings - Boot Settings ] ---------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Removal Media Settings ] ------------------- #

    iso_path     = "cephFS:iso"
    iso_file     = "Rocky-9.6-x86_64-dvd.iso"
    iso_checksum = "file:https://download.rockylinux.org/pub/rocky/9/isos/x86_64/CHECKSUM"

  #endregion --- [ Virtual Machine (VM) Settings - Removal Media Settings ] ------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Metadata ] --------------------------------- #

    vm_os_language   = "en_US"
    vm_os_keyboard   = "us"
    vm_os_timezone   = "UTC"
    vm_os_family     = "linux"
    vm_os_name       = "rocky"
    vm_os_version    = "9"

  #endregion --- [ Virtual Machine (VM) Settings - Metadata ] --------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Storage ] ---------------------------------- #

    //VM EFI Settings
    vm_efi_storage_pool      = "nvme-pool"
    vm_efi_type              = "4m"
    vm_efi_pre_enrolled_keys = false

    // UEFI VM Storage Settings
    vm_disk_device     = "vda"
    vm_disk_use_swap   = true
    vm_disk_partitions = [
      {
        name = "efi"
        size = 1024,
        format = {
          label  = "EFIFS",
          fstype = "fat32",
        },
        mount = {
          path    = "/boot/efi",
          options = "",
        },
        volume_group = "",
      },
      {
        name = "boot"
        size = 1024,
        format = {
          label  = "BOOTFS",
          fstype = "ext4",
        },
        mount = {
          path    = "/boot",
          options = "",
        },
        volume_group = "",
      },
      {
        name = "sysvg"
        size = -1,
        format = {
          label  = "",
          fstype = "",
        },
        mount = {
          path    = "",
          options = "",
        },
        volume_group = "sysvg",
      },
    ]

    vm_disk_lvm = [
      {
        name: "sysvg",
        partitions: [
          {
            name = "lv_swap",
            size = 1024,
            format = {
              label  = "SWAPFS",
              fstype = "swap",
            },
            mount = {
              path    = "",
              options = "",
            },
          },
          {
            name = "lv_root",
            size = 10240,
            format = {
              label  = "ROOTFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/",
              options = "",
            },
          },
          {
            name = "lv_home",
            size = 4096,
            format = {
              label  = "HOMEFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/home",
              options = "nodev,nosuid",
            },
          },
          {
            name = "lv_opt",
            size = 2048,
            format = {
              label  = "OPTFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/opt",
              options = "nodev",
            },
          },
          {
            name = "lv_tmp",
            size = 4096,
            format = {
              label  = "TMPFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/tmp",
              options = "nodev,noexec,nosuid",
            },
          },
          {
            name = "lv_var",
            size = 2048,
            format = {
              label  = "VARFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/var",
              options = "nodev",
            },
          },
          {
            name = "lv_var_tmp",
            size = 1000,
            format = {
              label  = "VARTMPFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/var/tmp",
              options = "nodev,noexec,nosuid",
            },
          },
          {
            name = "lv_var_log",
            size = 4096,
            format = {
              label  = "VARLOGFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/var/log",
              options = "nodev,noexec,nosuid",
            },
          },
          {
            name = "lv_var_audit",
            size = 500,
            format = {
              label  = "AUDITFS",
              fstype = "ext4",
            },
            mount = {
              path    = "/var/log/audit",
              options = "nodev,noexec,nosuid",
            },
          },
        ],
      }
    ]

  #endregion --- [ Virtual Machine (VM) Settings - Storage ] ---------------------------------- #

  #region ------ [ Virtual Machine (VM) Settings - Networking ] ------------------------------- #

    // Proxmox settings for VM templates
    vm_bridge_interface  = "vmbr0"
    vm_vlan_tag          = "228"

    // VM Network Settings
    vm_ip_address = "10.69.128.52"
    vm_ip_netmask = 24
    vm_ip_gateway = "10.69.128.1"
    vm_dns_list   = [ "10.69.128.1" ]

  #endregion --- [ Virtual Machine (VM) Settings - Networking ] ------------------------------- #

#endregion --- [ Virtual Machine (VM) Settings ] ---------------------------------------------- #

