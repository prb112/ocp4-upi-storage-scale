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

resource "null_resource" "daemon_init" {
  depends_on = [openstack_compute_instance_v2.daemon]

  count = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  # Configure password-less SSH 
  provisioner "file" {
    content     = sensitive(local.private_key)
    destination = ".ssh/id_rsa"
  }

  provisioner "file" {
    content     = sensitive(local.public_key)
    destination = ".ssh/id_rsa.pub"
  }


  provisioner "remote-exec" {
    inline = [
      <<EOF
sudo chmod 600 .ssh/id_rsa*
sudo sed -i.bak -e 's/^ - set_hostname/# - set_hostname/' -e 's/^ - update_hostname/# - update_hostname/' /etc/cloud/cloud.cfg
sudo hostnamectl set-hostname --static 'HOSTNAME=${lower(var.daemon["name_prefix"])}-scale-${count.index}.${var.daemon["domain_name"]}'
echo 'HOSTNAME=${lower(var.daemon["name_prefix"])}-scale-${count.index}.${var.daemon["domain_name"]}' | sudo tee -a /etc/sysconfig/network > /dev/null
sudo hostname -F /etc/hostname
echo 'vm.max_map_count = 262144' | sudo tee --append /etc/sysctl.conf > /dev/null
EOF
    ]
  }
}

resource "null_resource" "daemon_register" {
  depends_on = [null_resource.daemon_init]

  count = var.daemon["count"]

  triggers = {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  connection {
    type        = "ssh"
    user        = self.triggers.rhel_username
    host        = self.triggers.daemon_ip
    private_key = self.triggers.private_key
    agent       = self.triggers.ssh_agent
    timeout     = "${self.triggers.connection_timeout}m"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
# Give some more time to subscription-manager
sudo subscription-manager config --server.server_timeout=600
sudo subscription-manager clean
if [[ '${var.rhel_subscription["subscription_org"]}' == '' ]]; then
    sudo subscription-manager register --username='${var.rhel_subscription["username"]}' --password='${var.rhel_subscription["password"]}' --force
else
    sudo subscription-manager register --org='${var.rhel_subscription["subscription_org"]}' --activationkey='${var.rhel_subscription["activationkey"]}' --force
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
      type        = "ssh"
      user        = self.triggers.rhel_username
      host        = self.triggers.daemon_ip
      private_key = sensitive(self.triggers.private_key)
      agent       = self.triggers.ssh_agent
      timeout     = "${self.triggers.connection_timeout}m"
    }

    when       = destroy
    on_failure = continue
    inline = [
      "sudo subscription-manager unregister",
      "sudo subscription-manager remove --all",
    ]
  }
}

resource "null_resource" "daemon_packages" {
  depends_on = [null_resource.daemon_init, null_resource.daemon_register]

  count = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y --skip-broken",
      "sudo yum install -y wget jq git net-tools vim python3 tar"
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

  # setup chrony
  provisioner "remote-exec" {
    inline = [
      <<EOF
yum install -y chrony
systemctl enable chronyd
systemctl start chronyd
hostname --long 
date
EOF
    ]
  }

  # setup packages
  provisioner "remote-exec" {
    inline = [
      <<EOF
yum -y install 'kernel-devel-uname-r == $(uname -r)'
yum -y install cpp gcc gcc-c++ binutils
yum -y install 'kernel-headers-$(uname -r)' elfutils elfutils-devel make
done
yum -y install python3 ksh m4 boost-regex
yum -y install postgresql-server postgresql-contrib
yum -y install openssl-devel cyrus-sasl-devel
yum -y install nftables
EOF
    ]
  }

  # Update and Reboot
  provisioner "remote-exec" {
    inline = [
      <<EOF
yum update -y
systemctl reboot
EOF
    ]
  }
}

resource "time_sleep" "await_reboot" {
  depends_on       = [null_resource.daemon_packages]
  create_duration  = "120s"
  destroy_duration = "0s"
}

resource "null_resource" "await_start_up" {
  depends_on = [time_sleep.await_reboot]

  count = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = openstack_compute_instance_v2.daemon[count.index].access_ip_v4
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }
  provisioner "remote-exec" {
    inline = [
      <<EOF
uname -r
echo "Updated"
EOF
    ]
  }
}
