# ============================================================================================= #
# - File: .\builds.pkr.hcl                                                    | Version: v1.0.0 #
# --- [ Description ] ------------------------------------------------------------------------- #
#                                                                                               #
# ============================================================================================= #


# Build Definition to create the VM Template
build {
  sources = ["source.proxmox-iso.linux-rocky"]

  provisioner "ansible" {
    user                   = "${var.deploy_user_name}"
    galaxy_file            = "${path.cwd}/ansible/linux-requirements.yml"
    galaxy_force_with_deps = true
    playbook_file          = "${path.cwd}/ansible/linux-playbook.yml"
    roles_path             = "${path.cwd}/ansible/roles"
    ansible_env_vars = [
      "ANSIBLE_CONFIG=${path.cwd}/ansible/ansible.cfg"
    ]
    extra_arguments = [
      # Declare Connection Settings
      "--extra-vars", "ansible_user=${var.deploy_user_name}",
      "--extra-vars", "ansible_become_pass=${var.deploy_user_password}",

      # Provide Variables Needed In Playbook
      "--extra-vars", "deploy_user_key='${var.deploy_user_key}'",
      "--extra-vars", "enable_cloudinit='${var.vm_cloudinit}'"
    ]
  }

  post-processor "manifest" {
    output     = local.manifest_output
    strip_path = true
    strip_time = true
    custom_data = {
      build_username           = "${var.deploy_user_name}"
      build_date               = "${local.build_date}"
      build_version            = "${local.build_version}"
      common_data_source       = "${var.common_data_source}"
      vm_cpu_sockets           = "${var.vm_cpu_sockets}"
      vm_cpu_count             = "${var.vm_cpu_count}"
      vm_disk_size             = "${var.vm_disk_size}"
      vm_bios                  = "${var.vm_bios}"
      vm_os_type               = "${var.vm_os_type}"
      vm_mem_size              = "${var.vm_mem_size}"
      vm_network_card_model    = "${var.vm_network_card_model}"
      vm_cloud_init_enable     = "${var.vm_cloudinit}"
    }
  }
}
