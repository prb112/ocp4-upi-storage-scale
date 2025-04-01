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

resource "openstack_compute_keypair_v2" "key-pair" {
  count      = var.ssh["create_keypair"] == "" ? 0 : 1
  name       = var.ssh["keypair_name"]
  public_key = sensitive(local.public_key)
}