This modules uses an existing private network and assumes each instance is tuned to use the same MTU. The IPs are automatically provisioned for each instance.


> Provision at least two shared disks each with at least 100 GB size.

> Create two PVN INstances 
- Attach the shared disks to each of the VMs.
- Attach Private Net
- Attach Public Net per instance

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
