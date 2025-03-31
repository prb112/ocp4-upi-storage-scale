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

data "ibm_cis_domain" "domain" {
  cis_id = var.ibm_cloud_cis_crn
  domain = var.daemon["domain_name"]
}

resource "ibm_cis_dns_record" "daemon_scale" {
  count     = var.daemon["count"]
  cis_id    = var.ibm_cloud_cis_crn
  content   = var.daemon_ips[count.index]
  domain_id = data.ibm_cis_domain.domain.id
  name      = "${lower(var.daemon["name_prefix"])}-scale-${count.index}.${var.daemon["domain_name"]}"
  ttl       = 900
  type      = "A"
}