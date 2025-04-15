#!/bin/bash

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
# Â©Copyright IBM Corp. 2024
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Last updated: 09/29/2024
#
################################################################

# Origin https://s3.us.cloud-object-storage.appdomain.cloud/developer/default/tutorials/install-spectrum-scale-cnsa-5121-on-ocp-48-on-powervs/static/define_cluster.sh

# short hostnames of the 2-node cluster members
NODE_1="218018-linux-1"
NODE_2="218018-linux-2"

# device names of the shared disks as printed by: "multipath -ll 2>/dev/null | grep 'dm-\|size'"
DISK_1="dm-1"
DISK_2="dm-6"

# cluster name
CLUSTER_NAME="gpfs-tz-p9-cluster"

#################################
### do not modify below this line
#################################

cd /usr/lpp/mmfs/5.2.1.1/ansible-toolkit

# add all nodes
./spectrumscale node add ${NODE_1}
./spectrumscale node add ${NODE_2}

# specify admin node
./spectrumscale node add ${NODE_1} -a

# specify manager node
# -> let the toolkit automatically assign

# specify quorom nodes
# -> let the toolkit automatically assign

# specify gui nodes
./spectrumscale node add ${NODE_1} -g

# specify nsd nodes
./spectrumscale node add ${NODE_1} -n
./spectrumscale node add ${NODE_2} -n

# add NSD disks
# multipath -ll | grep mpath
# we need to use the dm-XXX device here.
#
./spectrumscale nsd add /dev/${DISK_1} -p ${NODE_1} -s ${NODE_2}
./spectrumscale nsd add /dev/${DISK_2} -p ${NODE_1} -s ${NODE_2}

# List NSD disks
./spectrumscale nsd list

# Add file systems
./spectrumscale nsd modify nsd1 -fs gpfs0
./spectrumscale nsd modify nsd2 -fs gpfs0

# Modify file systems
./spectrumscale filesystem modify -B 1M -r 1 -mr 1 -R 3 -MR 3 \
  --retention 365 --logfileset ".audit_log" gpfs0

# List file systems
./spectrumscale filesystem list

# specify cluster name
./spectrumscale config gpfs -c ${CLUSTER_NAME}

# configure ephemeral port range
./spectrumscale config gpfs --ephemeral_port_range 60000-61000

# print GPFS config
./spectrumscale config gpfs --list