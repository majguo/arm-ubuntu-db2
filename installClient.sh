#!/bin/sh
while getopts "l:u:g:p:" opt; do
    case $opt in
        l)
            db2InstallKitLocation=$OPTARG #SAS URI of the IBM DB2 Data Server Client install kit in Azure Storage
        ;;
        u)
            instName=$OPTARG #Instance name of IBM DB2 Data Server Client, up to 8 characters
        ;;
        g)
            instGroupName=$OPTARG #Instance group name of IBM DB2 Data Server Client, up to 8 characters
        ;;
        p)
            instPwd=$OPTARG #Instance password of IBM DB2 Data Server Client
        ;;
    esac
done

# Variables
db2InstallKitName=ibm_data_server_client_linuxx64_v11.5.tar.gz
db2clientRspFileLocation=https://raw.githubusercontent.com/majguo/arm-ubuntu-db2/master/db2client.rsp
db2clientRspFileName=db2client.rsp

# Install package dependencies of IBM DB2 Data Server Client
dpkg --add-architecture i386
apt-get update
apt-get install libx32stdc++6 --yes && apt-get install libpam0g:i386 --yes && apt-get install libaio1 --yes && apt-get install binutils

# Get DB2 Data Server Client Installation Kit
wget -O "$db2InstallKitName" "$db2InstallKitLocation"
tar -xf "$db2InstallKitName"

# Get DB2 Data Server Client response file template & replace placeholder strings with user-input parameters
wget -O "$db2clientRspFileName" "$db2clientRspFileLocation"
sed -i "s/DB2_INST_NAME/${instName}/g" "$db2clientRspFileName"
sed -i "s/DB2_INST_GROUP_NAME/${instGroupName}/g" "$db2clientRspFileName"
sed -i "s/DB2_INST_PASSWORD/${instPwd}/g" "$db2clientRspFileName"

# Create group and user for instance owner
groupadd -g 997 "$instGroupName" && useradd -p $(openssl passwd -1 "$instPwd") -u 1002 -g "$instGroupName" -m -d /home/"$instName" "$instName"

# Install IBM DB2 Data Server Client using response file
./client/db2setup -r "$db2clientRspFileName" -l log.txt