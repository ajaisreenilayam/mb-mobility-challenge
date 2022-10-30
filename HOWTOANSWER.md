# How to bring the applications to real life scenarios in production?

Now we have implemented the AKS cluster and the ACR in our Azure cloud. Now we will try to understand some common questions which will make our life easier to implement the application deployments to the AKS cluster using the various CI/CD methods.

* After setting up the Container Registry and the Kubernetes cluster, how would you bring your applications to life?

  - How to deploy the application?

    We can deploy the applications to the AKS cluster either in a manual or an automated way

    - Manual Deployments
      - kubectl apply -f <filename.yaml>
      - local helm charts or using helm install commands
    - Automated deployments
      - jenkins
      - argo cd
      - Gitlab runners
      - GitHub actions
      - Azure devops pipelines
  
  - Summarize all needed steps for an CI/CD pipeline to bring images living in the ACR to life in the AKS
  
    ## Using GitHub Action
      
    - We need to have a git repository with proper github action minutes
    - Create a service principal using the azure command
    ```
    az ad sp create-for-rbac \
    --name "ghActionMbmChallenge" \
    --scope /subscriptions/c1e45c6c-1ab0-4ebd-a77f-40b2316b9eaa/resourceGroups/mbm-rg-central-services \
    --role Contributor \
    --sdk-auth
    ```
    ```
    az ad sp create-for-rbac \
    --name "ghActionMbmChallenge" \
    --scope /subscriptions/c1e45c6c-1ab0-4ebd-a77f-40b2316b9eaa/resourceGroups/MC_mbm-rg-central-services_aks-mbm-westeurope-mbm-dev-blue_westeurope \
    --role Contributor \
    --sdk-auth
    ```
    You will be receiving a sample json as mentioned below as the output of the above command.
    ```
    {
    "clientId": "f318e148-9af6-4553-8f0c-xxxxxxxxxxxxxxxx",
    "clientSecret": "XON8Q~~Dfl0_Vd3NM7KrDNoxxxxxxxxxxxxxxxx",
    "subscriptionId": "c1e45c6c-1ab0-4ebd-a77f-xxxxxxxxxxxxxxxx",
    "tenantId": "685d03de-e19c-4a6e-b0a7-xxxxxxxxxxxxxxxx",
    "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
    "resourceManagerEndpointUrl": "https://management.azure.com/",
    "activeDirectoryGraphResourceId": "https://graph.windows.net/",
    "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
    "galleryEndpointUrl": "https://gallery.azure.com/",
    "managementEndpointUrl": "https://management.core.windows.net/"
    }
    ```

    - Copy the json output to the secrets of github secrets
    - also add the additional secrets required like
      - AZURE_CREDENTIALS: The entire JSON output from the az ad sp create-for-rbac command
      - service_principal: The value of <clientId>
      - service_principal_password:	The value of <clientSecret>
      - subscription: The value of <subscriptionId>
      - tenant: The value of <tenantId>:
      - registry: The name of your registry
      - repository:	Name of the repository you are planning to push inside this registry
      - resource_group:	The name of your resource group
      - cluster_name: The name of your cluster
    - Once you are ready with these secrets you can create the GitHub action file .github/workflows/main.yml.

      [Sample yaml for deployment pipeline](yaml_files/workflow.main.yaml)
    
    - The above yaml will create a sample nginx deployment and expose to the outside world using a loadbalancer. The nginx image will be pushed with the image version of the git commit sha value whenever there is a push event to the repository folder mbm-challenge/**

* Which additional Resources and Tools, inside or beside the kubernetes cluster are needed to access your applications running in the cluster?
  - How can you make your application reachable in the internet?
    - Public Load balancer or Public IP address or Public IP address associated with the DNS record.
    - If you would like to access the application just for testing purpose you can also use the kubectl forward command to a local-port of the laptop to expose to the local environment.

  - What can be used to bring some security to the applications and the AKS
    - The application has to secured in multiple levels
      - Code level: his has tobe taken cared from coding level, which we need to enforce the developers , not to use the hardcoded values inside the program and rather to use the secret or ConfigMaps
      - Code quality: Implement the code bug checks and code quality checking using the sonarqube 
      - Code vulnerability: CHeck the licensing vulnerabilities using the blackduck software.
    - Image scanner
      - The image scanning can be done with the software like trivy, and ensures that there is no vulnerable packages included
      - We can implement some software like Kyverno so that it will give features like
        - policies as Kubernetes resources (no new language to learn!)
        - validate, mutate, or generate any resource
        - match resources using label selectors and wildcards
    - General Kubernetes best practices can be followed
      - API server access by Azure AD and RBAC methods
      - Least privileged container, which does not have access to the nodes directly
      - Keep the latest version of patches and security standards always
    - Over All Azure Security
      - In order to maintain the over Azure security we can implement
        - Azure Web Application Firewall
        - DDoS Protection