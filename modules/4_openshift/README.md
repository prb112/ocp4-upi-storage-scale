https://www.ibm.com/support/fixcentral/swg/selectFixes?parent=Software%20defined%20storage&product=ibm/StorageSoftware/IBM+Storage+Scale&release=5.2.3&platform=Linux+PPC64LE&function=all&utm_source=ibm_developer



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
