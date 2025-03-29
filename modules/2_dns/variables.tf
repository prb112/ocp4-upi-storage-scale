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

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key associated with user's identity"
  default     = "<key>"
}

variable "ibmcloud_region" {
  description = "The IBM Cloud region where you want to create the resources"
  default     = ""
}

variable "ibmcloud_zone" {
  description = "The zone of an IBM Cloud region where you want to create Power System resources"
  default     = ""
}

variable "ibm_cloud_cis_crn" {}

variable "cluster_domain" {
  default = "example.com"
}

variable "name_prefix" {}

variable "daemon_ips" {}