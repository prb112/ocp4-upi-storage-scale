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

resource "null_resource" "install_scale" {
  count = var.daemon["count"]

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = var.daemon_ips[count.index]
    private_key = sensitive(var.ssh["private_key"])
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  #Download Storage Scale 5.2.1.1 installer from IBM Fix Central.
  #Install the Storage Scale 5.2.1.1 binary files.
  #Create a two-node Storage Scale cluster on the RHEL 9.4 VMs and the shared disks.
  #Prepare the Storage Scale 5.2.1.1 cluster for Storage Scale Container Native Storage Access 5.2.1.1.
  provisioner "remote-exec" {
    inline = [
      <<EOF

EOF
    ]
  }
}
