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

# Figures out the key files
locals {
  private_key_file = var.ssh["private_key_file"] == "" ? "${path.cwd}/data/id_rsa" : join("/", ["${path.cwd}", var.ssh["private_key_file"]])
  public_key_file  = var.ssh["public_key_file"] == "" ? "${path.cwd}/data/id_rsa.pub" : join("/", ["${path.cwd}", var.ssh["public_key_file"]])
  private_key      = file(coalesce(local.private_key_file, "/dev/null"))
  public_key       = file(coalesce(local.public_key_file, "/dev/null"))
}

resource "null_resource" "upload_scale" {
  count = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = var.daemon_ips[count.index]
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  # Report what is being uploaded
  provisioner "remote-exec" {
    inline = [
      <<EOF
echo "Uploading from ${var.scale["install"]}"
EOF
    ]
  }

  # Download Storage Scale 5.2.1.1 installer from IBM Fix Central.
  # Copy it to the data/ directory
  provisioner "file" {
    source      = "${path.module}/../../${var.scale["install"]}"
    destination = "/root/${var.scale["install"]}"
  }

  # Make the Storage Scale 5.2.1.1 binary files executable
  provisioner "remote-exec" {
    inline = [
      <<EOF
chmod u+x scale/${var.scale["install"]}
mkdir -p scale
mv ${var.scale["install"]} ./scale/${var.scale["install"]}
EOF
    ]
  }
}

resource "null_resource" "install_scale" {
  depends_on = [null_resource.upload_scale]
  count      = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = var.daemon_ips[count.index]
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  # Verify that the Storage Scale binary files have been installed on the node
  provisioner "remote-exec" {
    inline = [
      <<EOF
./scale/${var.scale["install"]} -y
rpm -qip /usr/lpp/mmfs/5.2.1.1/gpfs_rpms/gpfs.base*.rpm
EOF
    ]
  }

  # disable call home
  # list node configuration
  # run install precheck
  provisioner "remote-exec" {
    inline = [
      <<EOF
cd /usr/lpp/mmfs/5.2.1.1/ansible-toolkit
./spectrumscale callhome disable
./spectrumscale node list
./spectrumscale install -–precheck
EOF
    ]
  }

  # Install Spectrum Scale
  provisioner "remote-exec" {
    inline = [
      <<EOF
cd /usr/lpp/mmfs/5.2.1.1/ansible-toolkit
date
time ./spectrumscale install
date
EOF
    ]
  }

  # Create a two-node Storage Scale cluster on the RHEL 9.4 VMs and the shared disks.
  # achieve quorum on a two-node Storage Scale cluster.
  provisioner "remote-exec" {
    inline = [
      <<EOF
/usr/lpp/mmfs/bin/mmchconfig tiebreakerDisks=nsd1
EOF
    ]
  }

  # Setup the bash_profile
  provisioner "remote-exec" {
    inline = [
      <<EOF
echo "PATH=$PATH:$HOME/bin:/usr/lpp/mmfs/bin" >> ~/.bash_profile
EOF
    ]
  }

  # list the Storage Scale cluster definition, to verify that all cluster nodes are active, and to validate that the gpfs0 file system has been successfully mounted under /ibm/gpfs0.
  provisioner "remote-exec" {
    inline = [
      <<EOF
mmlscluster; echo; mmgetstate -a; echo; df -h
EOF
    ]
  }
}

# Prepare the Storage Scale 5.2.1.1 cluster for Storage Scale Container Native Storage Access 5.2.1.1.
resource "null_resource" "configure_for_ocp" {
  depends_on = [null_resource.install_scale]
  count      = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = var.daemon_ips[count.index]
    private_key = sensitive(local.private_key)
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  # Create a new GUI user for Storage Scale container native with username as cnss_storage_gui_user and password as cnss_storage_gui_password.
  provisioner "remote-exec" {
    inline = [
      <<EOF
/usr/lpp/mmfs/gui/cli/mkuser cnss_storage_gui_user -p cnss_storage_gui_password -g ContainerOperator --disablePasswordExpiry 1
EOF
    ]
  }

  # Create a new GUI group CSIadmin and a new GUI user for Storage Scale CSI with username as csi-storage-gui-user and password as csi-storage-gui-password.
  provisioner "remote-exec" {
    inline = [
      <<EOF
/usr/lpp/mmfs/gui/cli/mkusergrp CsiAdmin --role csiadmin
/usr/lpp/mmfs/gui/cli/mkuser csi-storage-gui-user -p csi-storage-gui-password -g CsiAdmin --disablePasswordExpiry 1
EOF
    ]
  }

  # Run the following commands to enable quota on the gpfs0 file system, to change SELinux setting and to enable the filesetdf option.
  # enable quota on filesystem used by csi
  # enable quota for root user
  # ensure selinux parameter is set to yes
  # enable filesetdf
  provisioner "remote-exec" {
    inline = [
      <<EOF
mmchfs gpfs0 -Q yes
mmchconfig enforceFilesetQuotaOnRoot=yes -i
mmchconfig controlSetxattrImmutableSELinux=yes -i
mmchfs gpfs0 --filesetdf
EOF
    ]
  }
}