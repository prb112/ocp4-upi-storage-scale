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
  disk_config = {
    volume_count = var.storage["number_volumes"]
    volume_size  = var.storage["volume_size"]
    disk_name    = "disk/pv-storage-disk"
  }
}

resource "openstack_blockstorage_volume_v3" "storage_volume" {
  count = var.storage["number_volumes"]

  name        = join("-", [var.daemon["name_prefix"], "storage-vol", tostring(count.index)])
  size        = var.storage["number_volumes"]
  volume_type = var.storage["volume_storage_template"]

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "storage_v_attach" {
  depends_on = [null_resource.daemon_init]

  // Need to generate a matrix
  for_each = {
    storage1 = {
      volume = 0
      daemon = 0
    }
    storage2 = {
      volume = 0
      daemon = 1
    }
    storage3 = {
      volume = 1
      daemon = 0
    }
    storage4 = {
      volume = 1
      daemon = 1
    }
  }

  volume_id   = openstack_blockstorage_volume_v3.storage_volume[each.value.volume].id
  instance_id = openstack_compute_instance_v2.daemon[each.value.daemon].id
}