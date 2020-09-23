# Workaround for Azure CLI issue
Some Azure CLI versions have a software issue related to *add-record* command.

[Bug with TTL in DNS record sets #12804](https://github.com/Azure/azure-cli/issues/12804)

With such versions of Azure CLI, you cannot change a TTL, even if you change it from a default value to any values on Azure DNS resource property.

In this document, I will show how to enable you to set arbitrary TTLs.

## Solution

1. Go to **Config mode** on WebUI
1. Open the property of *Azure DNS resource*
1. In **Recovery Operation**, click on **Settings**
1. Check **Execute Script after Activation** and click on **Settings**
1. Edit *rscextent.bat*

    Please add TTL update commands to **POSTSTART** section.

    e.g. rscextent.bat
    ```
    .
    .
    .

    :POSTSTART
    echo %CLP_GROUPNAME%
    echo %CLP_RESOURCENAME%

    cd <Path of Azure CLI>
    call .\az.cmd login --service-principal -u <User URI> --tenant <Tenant ID> -p <Path of Service Principal>
    call .\az.cmd network dns record-set a update -g <Resource Group Name> -z <Zone Name> -n <Record Set Name> --set ttl=<TTL>
    call .\az.cmd logout --username <User URI>
    .
    .
    .
    ```
1. Apply the configuration file