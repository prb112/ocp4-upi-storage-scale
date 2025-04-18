# ocp4-upi-storage-scale

*work in progress*

The [`ocp4-upi-storage-scale` project](https://github.com/IBM/ocp4-upi-storage-scale) provides Terraform based automation code to help with the deployment of [Storage Scale](https://github.com/linux-system-roles/nbde_server) on [IBM® PowerVC](https://www.ibm.com/products/powervc).

The code uses Terraform with a combination of YAML, TF and other files to coordinate the provisioning and setup of the relevant infrastructure.

*WARNING*: Only attaches 2 volumes! You *must* manually change to `Shared Volumes` in PowerVC.

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
$ cd ocp4-upi-storage-scale
```

## Setup Terraform Variables

Update following variables in the [var.tfvars](../var.tfvars) based on your environment.

Note: RHEL 9.4 and higher are th eonly supported versions.

## Start Install

Run the following commands from within the directory.

```
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

## PowerVS Prerequisites

Follow the [guide](docs/prereqs_powervs.md) to complete the PowerVS prerequisites.

## Tang Infra Install

Follow the [quickstart](docs/quickstart.md) guide for NBDE installation on PowerVS.

## Automation Host Prerequisites

- [Automation Host Prerequisites](#automation-host-prerequisites)
    - [Configure Your Firewall](#configure-your-firewall)
    - [Automation Host Setup](#automation-host-setup)
        - [Terraform](#terraform)
        - [PowerVS CLI](#powervs-cli)
        - [Git](#git)

### Automation Host Setup

Install the following packages on the automation host. Select the appropriate install binaries based on your automation host platform - Mac/Linux/Windows.

#### Terraform

**Terraform**: Please open the [link](https://www.terraform.io/downloads) for downloading the latest Terraform. For validating the version run `terraform version` command after install. Terraform version 1.5.0 and above is required.

Install Terraform and providers for Power environment:

1. Download and install the latest Terraform binary for `linux/ppc64le`
   from https://github.com/ppc64le-development/terraform-ppc64le/releases.
2. Download the required Terraform providers for Power into your TF project directory:

```
$ cd <path_to_TF_project>
$ mkdir -p ./providers
$ curl -fsSL https://github.com/ocp-power-automation/terraform-providers-power/releases/download/v0.11/archive.zip -o archive.zip
$ unzip -o ./archive.zip -d ./providers
$ rm -f ./archive.zip
```

3. Initialize Terraform at your TF project directory:

```
$ terraform init --plugin-dir ./providers
``` 

#### Git

**Git**:  Please refer to the [link](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for instructions on installing Git.

## Make It Better

For bugs/enhancement requests etc. please open a
GitHub [issue](https://github.com/ibm/powervs-tang-server-automation/issues)

## Contributing

Please see the [contributing doc](CONTRIBUTING.md) for more details.

PRs are most welcome !!

# Support

> Is this a Red Hat or IBM supported solution?

No, This is not supported.