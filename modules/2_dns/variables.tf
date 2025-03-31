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

################################################################
# Configure the IBM Cloud provider
################################################################

variable "ibmcloud" {
  description = "IBM Cloud Configuration"
  default = {
    # IBM Cloud API key associated with user's identity
    api_key = ""
    # The IBM Cloud region where you want to create the resources
    region = ""
    # The zone of an IBM Cloud region where you want to create Power System resources
    zone = ""
  }
}

################################################################
# Configure the Instance details
################################################################

variable "daemon" {
  description = ""
  default = {
    username                    = "root"
    name_prefix                 = ""
    count                       = 1
    instance_type               = ""
    domain_name                 = ""
    openstack_availability_zone = ""
    fips_compliant              = ""
    network_name                = ""
  }
}

variable "daemon_ips" {
  type = list(string)
}

variable "ibm_cloud_cis_crn" {
  description = "The CRN of the CIS instance where the domain's dns is hosted"
  type        = string
  default     = "ocp.local"
}