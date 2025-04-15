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

module "daemon" {
  source = "./modules/1_daemon"
  providers = {
    openstack = openstack.powervc
  }
  openstack         = var.openstack
  daemon            = var.daemon
  storage           = var.storage
  ssh               = var.ssh
  rhel_subscription = var.rhel_subscription
}

module "dns" {
  providers = {
    ibm = ibm.ibm-cloud
  }
  depends_on = [module.daemon]
  source     = "./modules/2_dns"

  ibmcloud          = var.ibmcloud
  ibm_cloud_cis_crn = var.ibm_cloud_cis_crn
  daemon            = var.daemon
  daemon_ips        = module.daemon.daemon_ips
}

module "scale" {
  depends_on = [module.dns]
  source     = "./modules/3_scale"

  daemon     = var.daemon
  daemon_ips = module.daemon.daemon_ips
  scale      = var.scale
  ssh        = var.ssh
}

module "openshift" {
  depends_on = [module.scale]
  source     = "./modules/4_openshift"

  openshift  = var.openshift
  daemon_ips = module.daemon.daemon_ips
  ssh        = var.ssh
  daemon     = var.daemon
}