# Deploy IBM DB2 Server Edition V11.5.0.0 with Azure ARM template and CLI

## Prerequisites
 - Register an [Azure subscription](https://azure.microsoft.com/en-us/)
 - Register an [IBM id](https://idaas.iam.ibm.com/idaas/mtfim/sps/authsvc?PolicyId=urn:ibm:security:authentication:asf:basicldapuser)
 - Download [IBM DB2 Server Edition V11.5 Installation Kit](https://www.ibm.com/account/reg/sg-en/signup?formid=urx-33669)
 - Install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

 ## Before using sample parameters.json
 - Replace "GEN-UNIQUE" with valid user id or password
 - For parameter value of "virtualMachineName" & "virtualNetworkName", suggest to replace "rgName" with your resource group name to ensure its uniqueness
 - For the remaining parameters, you can use their default values immediately or modify per your needs
 
 ## Deploy using template, parameters & script
 With the provided ARM template and parameters, 
 - Using deploy.azcli to deploy
     ```
     deploy.azcli -n <deploymentName> -f <installKitFile> -i <subscriptionId> -g <resourceGroupName> -l <resourceGroupLocation>
     ```

## After deployment
- If you check the resource group in [azure portal](https://portal.azure.com/), you will see related resources created
- If you have one IBM DB2 Data Server Client installed on virtual machine in the same virtual network, open VM resource blade and copy its private IP address, then catalog server node & database to [test the connectivity to database](https://www.ibm.com/support/knowledgecenter/en/SSEPGG_11.5.0/com.ibm.swg.im.dbclient.install.doc/doc/t0070357.html). To install IBM DB2 Data Server Client, first download it from [IBM website](https://www-01.ibm.com/marketing/iwm/iwm/web/download.do?source=swg-idsc97&transactionid=456003434&pageType=urx&S_PKG=linuxamd) with IBM id and upload to secure cloud storage (e.g., [Azure Storage](https://azure.microsoft.com/en-us/services/storage/)), then locate to [client](https://github.com/majguo/arm-ubuntu-db2/tree/master/client) directory and run the following commands to install on Ubuntu 18.04 LTS server:
    ```
    installClient.sh -l <cloudStorageUriToInstallKit> -u <db2InstanceOwnerName> -g <db2InstanceOwerGroup> -p <db2InstanceOwnerPassword>
    ```
