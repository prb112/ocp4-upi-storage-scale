################################################################
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2025
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################

locals {
    daemon_count = 2
}

resource "openstack_compute_keypair_v2" "key-pair" {
  count      = var.create_keypair
  name       = var.keypair_name
  public_key = sensitive(var.public_key)
}

resource "openstack_compute_flavor_v2" "daemon_scg" {
  count        = var.scg_id == "" ? 0 : 1
  name         = "${var.daemon["instance_type"]}-${random_id.label[0].hex}-scg"
  region       = data.openstack_compute_flavor_v2.daemon.region
  ram          = data.openstack_compute_flavor_v2.daemon.ram
  vcpus        = data.openstack_compute_flavor_v2.daemon.vcpus
  disk         = data.openstack_compute_flavor_v2.daemon.disk
  swap         = data.openstack_compute_flavor_v2.daemon.swap
  rx_tx_factor = data.openstack_compute_flavor_v2.daemon.rx_tx_factor
  is_public    = var.scg_flavor_is_public
  extra_specs  = merge(data.openstack_compute_flavor_v2.daemon.extra_specs, { "powervm:storage_connectivity_group" : var.scg_id })
}

data "openstack_compute_flavor_v2" "daemon" {
  name = var.daemon["instance_type"]
}

resource "openstack_compute_instance_v2" "daemon" {
  count = local.daemon_count

  name      = "${var.cluster_id}-daemon-${count.index}"
  image_id  = var.daemon["image_id"]
  flavor_id = var.scg_id == "" ? data.openstack_compute_flavor_v2.daemon.id : openstack_compute_flavor_v2.daemon_scg[0].id
  key_pair  = openstack_compute_keypair_v2.key-pair.0.name
  network {
    port = var.daemon_port_ids[count.index]
  }
  availability_zone = lookup(var.daemon, "availability_zone", var.openstack_availability_zone)
}

resource "null_resource" "daemon_init" {
  depends_on = [time_sleep.fips_wait_30_seconds]
  count      = local.daemon_count


  connection {
    type         = "ssh"
    user         = var.rhel_username
    host         = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key  = var.private_key
    agent        = var.ssh_agent
    timeout      = "${var.connection_timeout}m"
  }
  provisioner "remote-exec" {
    inline = [
      "whoami"
    ]
  }
  provisioner "file" {
    content     = var.private_key
    destination = ".ssh/id_rsa"
  }
  provisioner "file" {
    content     = var.public_key
    destination = ".ssh/id_rsa.pub"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 .ssh/id_rsa*",
      "sudo sed -i.bak -e 's/^ - set_hostname/# - set_hostname/' -e 's/^ - update_hostname/# - update_hostname/' /etc/cloud/cloud.cfg",
      "sudo hostnamectl set-hostname --static ${lower(var.cluster_id)}-daemon-${count.index}.${lower(var.cluster_id)}.${var.cluster_domain}",
      "echo 'HOSTNAME=${lower(var.cluster_id)}-daemon-${count.index}.${lower(var.cluster_id)}.${var.cluster_domain}' | sudo tee -a /etc/sysconfig/network > /dev/null",
      "sudo hostname -F /etc/hostname",
      "echo 'vm.max_map_count = 262144' | sudo tee --append /etc/sysctl.conf > /dev/null",
    ]
  }
}

resource "null_resource" "daemon_register" {
  count      = (var.rhel_subscription_username == "" || var.rhel_subscription_username == "<subscription-id>") && var.rhel_subscription_org == "" ? 0 : local.daemon_count
  depends_on = [null_resource.daemon_init]
  triggers = {
    daemon_ip         = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    rhel_username      = var.rhel_username
    private_key        = var.private_key
    ssh_agent          = var.ssh_agent
    jump_host          = var.jump_host
    connection_timeout = var.connection_timeout
  }

  connection {
    type         = "ssh"
    user         = self.triggers.rhel_username
    host         = self.triggers.daemon_ip
    private_key  = self.triggers.private_key
    agent        = self.triggers.ssh_agent
    timeout      = "${self.triggers.connection_timeout}m"
  }

  provisioner "remote-exec" {
    inline = [<<EOF

# Give some more time to subscription-manager
sudo subscription-manager config --server.server_timeout=600
sudo subscription-manager clean
if [[ '${var.rhel_subscription_org}' == '' ]]; then
    sudo subscription-manager register --username='${var.rhel_subscription_username}' --password='${var.rhel_subscription_password}' --force
else
    sudo subscription-manager register --org='${var.rhel_subscription_org}' --activationkey='${var.rhel_subscription_activationkey}' --force
fi
sudo subscription-manager refresh
sudo subscription-manager attach --auto

EOF
    ]
  }
  # Delete Terraform files as contains sensitive data
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /tmp/terraform_*"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type         = "ssh"
      user         = self.triggers.rhel_username
      host         = self.triggers.daemon_ip
      private_key  = self.triggers.private_key
      agent        = self.triggers.ssh_agent
      timeout      = "${self.triggers.connection_timeout}m"
    }

    when       = destroy
    on_failure = continue
    inline = [
      "sudo subscription-manager unregister",
      "sudo subscription-manager remove --all",
    ]
  }
}

resource "null_resource" "enable_repos" {
  count      = local.daemon_count
  depends_on = [null_resource.daemon_init, null_resource.daemon_register]

  connection {
    type        = "ssh"
    user        = var.rhel_username
    host        = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key = var.private_key
    agent       = var.ssh_agent
    timeout     = "${var.connection_timeout}m"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
# Additional repo for installing ansible package
if ( [[ -z "${var.rhel_subscription_username}" ]] || [[ "${var.rhel_subscription_username}" == "<subscription-id>" ]] ) && [[ -z "${var.rhel_subscription_org}" ]]; then
  sudo yum install -y epel-release
  sudo yum install -y ansible
elif [[ "$(printf '%s\n' "8.5" "$(cat /etc/redhat-release | sed 's/[^0-9.]*//g')" | sort -V | head -n1)" == "8.5" ]]; then
  # Compared release version with 8.5 (eg: 8.10 > 8.5)
  sudo yum install -y ansible-core
else
  sudo subscription-manager repos --enable ${var.ansible_repo_name}
  sudo yum install -y ansible
fi
EOF
    ]
  }
}

resource "null_resource" "daemon_packages" {
  count      = local.daemon_count
  depends_on = [null_resource.daemon_init, null_resource.daemon_register, null_resource.enable_repos]

  connection {
    type         = "ssh"
    user         = var.rhel_username
    host         = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key  = var.private_key
    agent        = var.ssh_agent
    timeout      = "${var.connection_timeout}m"
  }
  provisioner "remote-exec" {
    inline = [
      "#sudo yum update -y --skip-broken",
      "sudo yum install -y wget jq git net-tools vim python3 tar"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-galaxy collection install community.crypto",
      "ansible-galaxy collection install ansible.posix",
      "ansible-galaxy collection install kubernetes.core"
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo systemctl unmask NetworkManager",
      "sudo systemctl start NetworkManager",
      "for i in $(nmcli device | grep unmanaged | awk '{print $1}'); do echo NM_CONTROLLED=yes | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-$i; done",
      "sudo systemctl restart NetworkManager",
      "sudo systemctl enable NetworkManager"
    ]
  }
}

resource "openstack_blockstorage_volume_v3" "storage_volume" {
  count = var.shared_volume_count

  name        = "${var.name_prefix}-storage-vol-${count.index}"
  size        = var.volume_size
  volume_type = var.volume_storage_template
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "storage_v_attach" {
  depends_on = [null_resource.daemon_init]
  count      = var.storage_type == "nfs" ? 1 : 0

  volume_id   = openstack_blockstorage_volume_v3.storage_volume[count.index].id
  instance_id = openstack_compute_instance_v2.daemon[count.index].id
}

locals {
  disk_config = {
    volume_size = var.volume_size
    disk_name   = "disk/pv-storage-disk"
  }
}

resource "null_resource" "setup_shared_disk" {
  count      = var.shared_volume_count
  depends_on = [openstack_compute_volume_attach_v2.storage_v_attach]

  connection {
    type         = "ssh"
    user         = var.rhel_username
    host         = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key  = var.private_key
    agent        = var.ssh_agent
    timeout      = "${var.connection_timeout}m"
  }
  provisioner "file" {
    content     = templatefile("${path.module}/templates/create_disk_link.sh", local.disk_config)
    destination = "/tmp/create_disk_link.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf mkdir ${local.storage_path}; sudo mkdir -p ${local.storage_path}; sudo chmod -R 755 ${local.storage_path}",
      "sudo chmod +x /tmp/create_disk_link.sh",
      # Fix for copying file from Windows OS having CR,
      "sudo sed -i 's/\r//g' /tmp/create_disk_link.sh",
      "sudo /tmp/create_disk_link.sh",
      "sudo mkfs.xfs /dev/${local.disk_config.disk_name}",
      "MY_DEV_UUID=$(sudo blkid -o export /dev/${local.disk_config.disk_name} | awk '/UUID/{ print }')",
      "echo \"$MY_DEV_UUID ${local.storage_path} xfs defaults 0 0\" | sudo tee -a /etc/fstab > /dev/null",
      "sudo mount ${local.storage_path}",
    ]
  }
}