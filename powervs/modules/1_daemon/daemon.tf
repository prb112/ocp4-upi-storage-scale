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

resource "openstack_compute_instance_v2" "daemon" {
  count     = var.daemon["count"]
  name      = join("-", [var.daemon["name_prefix"], "daemon", "${count.index}"])
  image_id  = var.daemon["image_id"]
  flavor_id = var.storage["scg_id"] == "" ? data.openstack_compute_flavor_v2.daemon.id : openstack_compute_flavor_v2.daemon_scg[0].id
  key_pair  = openstack_compute_keypair_v2.key-pair.0.name
  network {
    name = data.openstack_networking_network_v2.network.name
  }
  availability_zone = lookup(var.daemon, "availability_zone", var.daemon["openstack_availability_zone"])
}