#!/bin/sh
while getopts "l:a:b:c:d:e:f:g:h:i:j:" opt; do
    case $opt in
        l)
            db2InstallKitLocation=$OPTARG #SAS URI of the IBM DB2 install kit in Azure Storage
        ;;
        a)
            instName=$OPTARG #Instance name of IBM DB2 Server
        ;;
        b)
            instGroupName=$OPTARG #Instance group name of IBM DB2 Server
        ;;
        c)
            instPwd=$OPTARG #Instance password of IBM DB2 Server
        ;;
        d)
            fencedName=$OPTARG #Fenced user name of IBM DB2 Server
        ;;
        e)
            fencedGroupName=$OPTARG #Fenced user group name of IBM DB2 Server
        ;;
        f)
            fencedPwd=$OPTARG #Fenced user password of IBM DB2 Server
        ;;
        g)
            dbName=$OPTARG #Database name of IBM DB2 Server
        ;;
        h)
            dbAlias=$OPTARG #Database alias of IBM DB2 Server
        ;;
        i)
            dbUserName=$OPTARG #Database user name of IBM DB2 Server
        ;;
        j)
            dbUserPwd=$OPTARG #Database user password of IBM DB2 Server
        ;;
    esac
done

# Variables
db2InstallKitName=v11.5_linuxx64_dec.tar.gz
db2serverRspFileName=db2server.rsp
dbGroupName="$dbUserName"grp

# Install package dependencies of IBM DB2
dpkg --add-architecture i386
apt-get update
apt-get install libx32stdc++6 --yes && apt-get install libpam0g:i386 --yes && apt-get install libaio1 --yes

# Get DB2 Installation Kit
wget -O "$db2InstallKitName" "$db2InstallKitLocation"
tar -xf v11.5_linuxx64_dec.tar.gz

# Get DB2 server response file template & replace placeholder strings with user-input parameters
wget https://raw.githubusercontent.com/majguo/arm-ubuntu-db2/master/"$db2serverRspFileName"
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
./server_dec/db2setup -r db2server.rsp -l log.txt