################################################################
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
################################################################

openstack = {
  # The endpoint URL used to connect to OpenStack/PowerVC
  auth_url = "https://<HOSTNAME>:5000/v3/"
  # The user name used to connect to OpenStack/PowerVC
  user_name = ""
  # The password for the user
  password = ""
  # The name of the project (a.k.a. tenant) used
  tenant_name = "ibm-default"
  # The domain to be used
  domain_name = "Default"
  # Default is INSECURE
  insecure = "true"
  # The name of Availability Zone for deploy operation
  openstack_availability_zone = ""
}

ibmcloud = {
  # IBM Cloud API key associated with user's identity
  api_key = ""
  # The IBM Cloud region where you want to create the resources
  region = ""
  # The zone of an IBM Cloud region where you want to create Power System resources
  zone = ""
}

ibm_cloud_cis_crn = "ocp.local"

################################################################
# Configure the Instance details
################################################################

daemon = {
  username                    = "root"
  name_prefix                 = ""
  count                       = 1
  instance_type               = ""
  domain_name                 = ""
  openstack_availability_zone = ""
  fips_compliant              = ""
  network_name                = ""
}

rhel_subscription = {
  username         = ""
  password         = ""
  subscription_org = ""
  activationkey    = ""
}

storage = {
  "scg_id"                  = ""
  "scg_flavor_is_public"    = ""
  "storage_type"            = ""
  "volume_size"             = ""
  "volume_storage_template" = ""
  "number_volumes"          = 2
  # The storage is protected. The lifecycle prevent_destroy is true
}

################################################################
# Configure the OpenStack SSH Key
################################################################

ssh = {
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

  agent              = true
  connection_timeout = "60m"

}

################################################################
# Configure the OpenShift
################################################################

openshift = {
  api_url    = "root"
  user       = ""
  pass       = 1
  bastion_ip = ""
}
