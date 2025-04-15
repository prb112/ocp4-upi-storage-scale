# ocp4-upi-storage-scale

The [`ocp4-upi-storage-scale` project](https://github.com/IBM/ocp4-upi-storage-scale) provides Terraform based automation code to help with the deployment of [Storage Scale](https://github.com/linux-system-roles/nbde_server) on [IBM® PowerVC](https://www.ibm.com/products/powervc) and [IBM® PowerVS](https://www.ibm.com/products/powervs).

The code uses Terraform with a combination of YAML, TF and other files to coordinate the provisioning and setup of the relevant infrastructure.

*WARNING*: Only attaches 2 volumes in PowerVC! You *must* manually change to `Shared Volumes` in PowerVC.

# Installation Quickstart

- [Installation Quickstart](#installation-quickstart)
    - [Download the Automation Code](#download-the-automation-code)
    - [Setup Terraform Variables](#setup-terraform-variables)
    - [Start Install](#start-install)
    - [Post Install](#post-install)
    - [Destroy Tang Server](#destroy-tang-server)

## Download the Automation Code

You'll need to use git to clone the deployment code when working off the main branch

```
$ git clone https://github.com/prb112/ocp4-upi-storage-scale
$ cd ocp4-upi-storage-scale/powervs
```

## Setup Terraform Variables

Update following variables in the [var.tfvars](../var.tfvars) based on your environment.

Note: RHEL 9.4 and higher are th eonly supported versions.

## Start Install

Run the following commands from within the directory.

```
$ cd powervs
$ terraform init
$ terraform plan -var-file=var.tfvars
$ terraform apply -var-file=var.tfvars
```

Note: Terraform Version should be ~>1.5.0

Now wait for the installation to complete. It may take around 20 mins to complete provisioning.

On successful install cluster details will be printed as shown below.

```
bastion_ip = [
  "193.168.*.*",
]
bastion_public_ip = [
  "163.68.*.*",
]
```

These details can be retrieved anytime by running the following command from the root folder of the code

```
$ terraform output
```

In case of any errors, you'll have to re-apply.

## Destroy Tang Server

Destroy the Tang Server

```
$ terraform destroy -var-file var.tfvars
```

## Automation Host Prerequisites

The automation needs to run from a system with internet access. This could be your laptop or a VM with public internet
connectivity. This automation code have been tested on the following Operating Systems:

- Mac OSX (Darwin)
- Linux (x86_64/ppc64le)
- Windows 10

Follow the [guide](docs/automation_host_prereqs.md) to complete the prerequisites.

## Contributing

Please see the [contributing doc](CONTRIBUTING.md) for more details.

PRs are most welcome !!

# Support

> Is this a Red Hat or IBM supported solution?

No, This is not supported.