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

data "openstack_compute_flavor_v2" "daemon" {
  name = var.daemon["instance_type"]
}

resource "openstack_compute_flavor_v2" "daemon_scg" {
  count        = var.storage["scg_id"] == "" ? 0 : 1
  name         = "${var.daemon["instance_type"]}-scg"
  region       = data.openstack_compute_flavor_v2.daemon.region
  ram          = data.openstack_compute_flavor_v2.daemon.ram
  vcpus        = data.openstack_compute_flavor_v2.daemon.vcpus
  disk         = data.openstack_compute_flavor_v2.daemon.disk
  swap         = data.openstack_compute_flavor_v2.daemon.swap
  rx_tx_factor = data.openstack_compute_flavor_v2.daemon.rx_tx_factor
  is_public    = var.storage["scg_flavor_is_public"]
  extra_specs  = merge(data.openstack_compute_flavor_v2.daemon.extra_specs, { "powervm:storage_connectivity_group" : var.storage["scg_id"] })
}