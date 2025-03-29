https://www.ibm.com/support/fixcentral/swg/selectFixes?parent=Software%20defined%20storage&product=ibm/StorageSoftware/IBM+Storage+Scale&release=5.2.2&platform=Linux+PPC64LE&function=all&utm_source=ibm_developer

> Create a Private Net
> change the default MTU to 1450 for the instance

> Create a Pub Net for each Instance

> Provision at least two shared disks each with at least 100 GB size.

> Create two PVN INstances 
- Attach the shared disks to each of the VMs.
- Attach Private Net
- Attach Public Net per instance

> Create DNS entries for RHEL9.4 Nodes


> null_provisioner
yum update -y
systemctl reboot

> null provisioner
uname -r

> null_provisioner - ssh setup
> Configure password-less SSH by performing the following steps (that is, step 4 to step 8). The nodes in the cluster must be able to communicate with each other without the use of a password for the root user and without the remote shell displaying any extraneous output.
ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
scp ~/.ssh/* 218018-linux-2:/root/.ssh

> null_provisioner - ssh setup with shortname
- use template...
cat > /nodes << EOF
218018-linux-1 
218018-linux-2 
EOF

> null_provisioner - setup chrony
for node in `cat /nodes`
do echo ""
echo "===== $node ====="
ssh $node "yum install -y chrony; systemctl enable chronyd; systemctl start chronyd"
done

> verify chrony 
for node in `cat /nodes`
do echo ""
echo "===== $node ====="
ssh $node "date"
done

> null provisioner
for node in `cat /nodes`
do echo ""
echo "===== $node ====="
ssh $node "yum -y install 'kernel-devel-uname-r == $(uname -r)'"
ssh $node "yum -y install cpp gcc gcc-c++ binutils"
ssh $node "yum -y install 'kernel-headers-$(uname -r)' elfutils elfutils-devel make"
done
for node in `cat /nodes`
do echo ""
echo "===== $node ====="
ssh $node "yum -y install python3 ksh m4 boost-regex"
ssh $node "yum -y install postgresql-server postgresql-contrib"
ssh $node "yum -y install openssl-devel cyrus-sasl-devel"
ssh $node "yum -y install nftables"
done





    Download Storage Scale 5.2.1.1 installer from IBM Fix Central.
    Install the Storage Scale 5.2.1.1 binary files.
    Create a two-node Storage Scale cluster on the RHEL 9.4 VMs and the shared disks.
    Prepare the Storage Scale 5.2.1.1 cluster for Storage Scale Container Native Storage Access 5.2.1.1.
    Prepare the OpenShift 4.14 cluster for Storage Scale Container Native Storage Access 5.2.1.1.
    Install Storage Scale Container Native Storage Access 5.2.1.1 on the OpenShift 4.14 cluster.
