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

################################################################
# Configure the OpenStack SSH Key
################################################################

variable "ssh" {
  default = {
    create_keypair = ""

    # Set this variable to the name of an already generated
    # keypair to use it instead of creating a new one.
    keypair_name = ""

    # Path to public key file
    # if empty, will default to ${path.cwd}/data/id_rsa.pub
    public_key_file = "data/id_rsa.pub"

    # Path to public key file
    # if empty, will default to ${path.cwd}/data/id_rsa
    private_key_file = "data/id_rsa"

    ssh_agent          = true
    connection_timeout = "60m"
  }
}

################################################################
# Configure the Scale
################################################################

variable "scale" {
  description = "The scale install details"
  default = {
    install = "data/Storage_Scale_Advanced-5.2.2.1-ppc64LE-Linux-install"
  }
}