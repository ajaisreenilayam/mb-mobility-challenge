# Mercedes Benz Mobility Challenge 

The goal of this coding test is for to show that we are generally comfortable working with the tools we use to develop our infrastructure.

## Pre-Requisites

- Create your azure subscription: https://portal.azure.com/#home
- terraform CLI: https://www.terraform.io/downloads
- azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli

## How to get started?

  Start by login to the azure cli and set your environment

```
      az login # To log in to the Azure CLI environment
      az account  set --subscription "your-sub-id" # To set the Azure subscription, if you have multiple subscription
```
- How to create the first remote state storing location? This is always considered as chicken-egg problem,  Hence, I thought of taking two approaches for this
  
  - Either you can do it with azure commands as following

```
      az group create --location westeurope --resource-group mb-mobility-services
      az storage account create --name mbmtfstatebackend  --resource-group mb-mobility-services --location westeurope --sku Standard_LRS
      az storage container create --name tfstate --account-name mbmtfstatebackend
```

  - Or you can use terraform script provided in the /terraform/mbmRemoteStateSetup folder, which uses a local terraform state

```
      terraform init
      terraform validate
      terrafrom apply
```

  - Then you can run change to the directory /terraform/mbmAKS folder, which uses a remote storage which we created using one of the methods.

```
      terraform init
      terraform validate
      terrafrom apply
```

## I have created simple shell script to create the entire infra, Which helps you to avoid all the above steps.

 - Steps to follow: 

    - `az login`: To login to the azure cli
    - `cd terraform`: Change directory to the unzipped folder
    - `./start.sh autoapply`: You can use this command to create the infrastructure automatically without entering  "yes" to terraform
    - `./start.sh apply`: You can use this command to create the infrastructure by manually entering "yes" to terraform
      - Note you need to type `yes` two time, First time for creating the storage account, container and Second time for AKS cluster
    - `az aks get-credentials --admin --name aks-mbm-westeurope-mbm-dev-blue --resource-group mbm-rg-central-services`: To get the kubeconfig to local
    - `./start.sh autodestroy`: You can use this command to destroy the infrastructure automatically without entering `yes` to terraform
    - `./start.sh destroy`: You can use this command to destroy the infrastructure by manually entering  `yes` to terraform
      - Note you need to type `yes` two time, First time for creating the storage account, container and Second time for AKS cluster
      

## Azure commands used

  - `az login`: To log in to the Azure CLI environment
  - `az account  set --subscription "your-sub-id"`: To set the Azure subscription, if you have multiple subscription
  - `az acr login -n mbmAzureContainerRegistry`: To log in to the azure container registry from CLI
  - `az aks get-credentials --admin --name aks-mbm-westeurope-mbm-dev-blue --resource-group mbm-rg-central-services`: To get the kubeconfig to local
  - `az storage account list`: To show the storage account created for the remote terraform state storage

## Commands used setting up the infrastructure

- `terraform plan`: To see what is going to create/destroy/change(s) to the infrastructure
- `terraform validate`: To validating the code written in HCL.
- `terraform apply`: Apply the changes according to the plan above
- `terraform destroy`: Destroy the infrastructure we have created using to terraform

## What and all resources are going to be deployed?

1. Resource Group: For holding the resources we are going to create
2. Network Security Group: Which is allowing the incoming and outgoing traffic
3. Virtual Network: A VPC for this
4. Subnets: Essential subnets which is a part of the Azure Virtual Network
5. Container Registry: This will be holding the containers which we are going to deploy to the AKS cluster
6. Application: When authenticated with a user principal, this resource requires one of the following directory roles: Application Administrator or Global Administrator
7. Service Principal: This is an automation account which can be used for. EG:  CI/CD Deployments, Terraform accounts etc 
8. Key Vault: This can be used for storing the secrets and other sensitive information required for the project
9. Access Policy: For the above created key vault we are assigning the policies
10. Log Analytics Workspace: All monitoring solutions requires to store collected data and to host log searches and views
11. Log Analytics Solution: Solutions are installed on your workspaces
12. Public IP: We will be assigning this IP address to the Cluster loadbalancer to access from the external world
13. AKS: This will create the azure kubernetes cluster with the help of the module which we have defined 
14. AKS will create its own resource group to hold all the AKS, and it's related components



