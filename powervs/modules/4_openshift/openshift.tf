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

resource "null_resource" "setup_openshift" {

  connection {
    type        = "ssh"
    user        = var.daemon["username"]
    host        = var.openshift["bastion_ip"]
    private_key = sensitive(var.ssh["private_key"])
    agent       = var.ssh["agent"]
    timeout     = var.ssh["connection_timeout"]
  }

  provisioner "remote-exec" {
    inline = [
      <<EOF

EOF
    ]
  }
}
