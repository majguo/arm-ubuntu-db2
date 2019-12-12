#!/bin/sh
# Parameters
db2InstallKitLocation=$1 #SAS URI of the IBM DB2 install kit in Azure Storage
instName=$2 #Instance name of IBM DB2 Server, up to 8 characters
instGroupName=$3 #Instance group name of IBM DB2 Server, up to 8 characters
instPwd=$4 #Instance password of IBM DB2 Server
fencedName=$5 #Fenced user name of IBM DB2 Server, up to 8 characters
fencedGroupName=$6 #Fenced user group name of IBM DB2 Server, up to 8 characters
fencedPwd=$7 #Fenced user password of IBM DB2 Server
dbName=$8 #Database name of IBM DB2 Server
dbUserName=$9 #Database user name of IBM DB2 Server
dbUserPwd=${10} #Database user password of IBM DB2 Server

# Variables
dbAlias="$dbName"
dbGroupName="$dbUserName"grp
db2InstallKitName=v11.5_linuxx64_dec.tar.gz
db2serverRspFileLocation=https://raw.githubusercontent.com/majguo/arm-ubuntu-db2/master/db2server.rsp
db2serverRspFileName=db2server.rsp

# Install package dependencies of IBM DB2 Server
dpkg --add-architecture i386
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
apt-get update
apt-get install libx32stdc++6 -y && apt-get install libpam0g:i386 -y && apt-get install libaio1 -y && apt-get install binutils -y

# Get DB2 Installation Kit
wget -O "$db2InstallKitName" "$db2InstallKitLocation"
tar -xf "$db2InstallKitName"

# Get DB2 server response file template & replace placeholder strings with user-input parameters
wget -O "$db2serverRspFileName" "$db2serverRspFileLocation"
sed -i "s/DB2_INST_NAME/${instName}/g" "$db2serverRspFileName"
sed -i "s/DB2_INST_GROUP_NAME/${instGroupName}/g" "$db2serverRspFileName"
sed -i "s/DB2_INST_PASSWORD/${instPwd}/g" "$db2serverRspFileName"
sed -i "s/DB2_INST_FENCED_USERNAME/${fencedName}/g" "$db2serverRspFileName"
sed -i "s/DB2_INST_FENCED_GROUP_NAME/${fencedGroupName}/g" "$db2serverRspFileName"
sed -i "s/DB2_INST_FENCED_PASSWORD/${fencedPwd}/g" "$db2serverRspFileName"
sed -i "s/DB2_DATABASE_NAME/${dbName}/g" "$db2serverRspFileName"
sed -i "s/DB2_DATABASE_ALIAS/${dbAlias}/g" "$db2serverRspFileName"
sed -i "s/DB2_DATABASE_USERNAME/${dbUserName}/g" "$db2serverRspFileName"
sed -i "s/DB2_DATABASE_PASSWORD/${dbUserPwd}/g" "$db2serverRspFileName"

# Create groups and users for instance owner, fenced user & database user
groupadd -g 997 "$instGroupName" && useradd -p $(openssl passwd -1 "$instPwd") -u 1002 -g "$instGroupName" -m -d /home/"$instName" "$instName"
groupadd -g 998 "$fencedGroupName" && useradd -p $(openssl passwd -1 "$fencedPwd") -u 1003 -g "$fencedGroupName" -m -d /home/"$fencedName" "$fencedName"
groupadd -g 999 "$dbGroupName" && useradd -p $(openssl passwd -1 "$dbUserPwd") -u 1004 -g "$dbGroupName" -m -d /home/"$dbUserName" "$dbUserName"

# Install IBM DB2 Server using response file
./server_dec/db2setup -r "$db2serverRspFileName" -l log.txt

# Install sample database as instance owner
sudo -i -u "$instName" sh -c 'db2sampl'
