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

#  resource "openstack_blockstorage_volume_type_v3" "multiattach" {
#    name        = "multiattach"
#    description = "Multiattach-enabled volume type"
#    extra_specs = {
#        multiattach = "True"
#    }
#    is_public = false
#    //var.storage["volume_type"]
# }

resource "openstack_blockstorage_volume_type_v3" "multiattach" {
  name        = "multiattach"
  description = "Multiattach-enabled volume type"
  extra_specs = {
    multiattach = "<is> True"
  }
}

resource "openstack_blockstorage_volume_v3" "storage_volume" {
  count = var.storage["number_volumes"]

  name        = join("-", [var.daemon["name_prefix"], "storage-vol", tostring(count.index)])
  size        = var.storage["volume_size"]
  volume_type = var.storage["volume_type"]

  lifecycle {
    prevent_destroy = false
  }
}

# Dev note: A complicated for-each is used, and fails to attach

# resource "openstack_compute_volume_attach_v2" "storage_v_attach" {
#   depends_on = [null_resource.daemon_init]
#   // Need to generate a matrix
#   for_each = {
#     storage1 = {
#       volume = 0
#       daemon = 0
#     }
#     storage2 = {
#       volume = 0
#       daemon = 1
#     }
#     storage3 = {
#       volume = 1
#       daemon = 0
#     }
#     storage4 = {
#       volume = 1
#       daemon = 1
#     }
#   }

#   volume_id   = openstack_blockstorage_volume_v3.storage_volume[each.value.volume].id
#   instance_id = openstack_compute_instance_v2.daemon[each.value.daemon].id
# }

resource "openstack_compute_volume_attach_v2" "storage_v_attach_volume_1" {
  count      = 2
  depends_on = [null_resource.daemon_init]

  instance_id = openstack_compute_instance_v2.daemon[0].id
  volume_id   = openstack_blockstorage_volume_v3.storage_volume[count.index].id

  multiattach = true
}

resource "openstack_compute_volume_attach_v2" "storage_v_attach_volume_2" {
  count      = 2
  depends_on = [openstack_compute_volume_attach_v2.storage_v_attach_volume_1]

  instance_id = openstack_compute_instance_v2.daemon[1].id
  volume_id   = openstack_blockstorage_volume_v3.storage_volume[count.index].id

  multiattach = true
}