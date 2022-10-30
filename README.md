# Mercedes-Benz Mobility Infrastructure Challenge

To proceed with your interview process at MBM, we have prepared a
short coding exercise for you.

The goal of this coding test is for you, to show that you are generally
comfortable working with the tools we use to develop our infrastructure.

In case you have any questions, feel free to reach out to us at:
<sameera.fonseka@mercedes-benz.com>

If you think some parts take too long for you to figure out and/or you don't
feel comfortable with, we'll also be able to help. So please don't get blocked by
that and you'll be able to continue completing the remaining parts of this
challenge.

**Please briefly document what you've done (e.g. in a `README.md`), what are
shortcomings of your solution, why you've taken them and where you see potential
for future work, i.e. what else would you implement that are not direct
requirements.**

## Basic Azure Terraform Infrastructure

#### The goal is to create the Terraform code for an initial infrastructure on Azure

In order for this Azure Resources to be reproducible, please setup everything with
[terraform](https://www.terraform.io/) and provide the code as your solution.

The requirements are:
* Central terraform state: set up to support multiple persons working on the infrastructure 
* Wherever applicable use exactly 2 AvailabilityZones and choose locations preferred in Germany and if not possible in WestEurope
* Create a Container Registry as central solution for all our software images
* Create a Kubernetes Cluster by creating a root module which is using the child-module in `/modules/aks/aks_module.tf` (edit/add/delete the module content only if needed!)



#### Answer following questions in a markdown file
* After setting up the Container Registry and the Kubernetes cluster, how would you bring your applications to life?
  - How to deploy the application?
  - Summarize all needed steps for an CI/CD pipeline to bring images living in the ACR to life in the AKS
* Which additional Resources and Tools, inside or beside the kubernetes cluster are needed to access your applications running in the cluster?
  - How can you make your application reachable in the internet?
  - What can be used to bring some security to the applications and the AKS


## Submit your solution

Please submit your solution by sending it as archive to <sameera.fonseka@mercedes-benz.com>, so we can verify your solution.
