# For Text Colours
RED='\033[1;31m'    # Bold Red
GREEN='\033[1;32m'  # Bold Green
NC='\033[0m'        # No Color
PUR='\033[0;35m'    # Purple
YELLOW='\033[0;33m' # Yellow


# To Crete the infrastructure manually by explicitly giving "Yes"
apply(){
  cd mbmRemoteStateSetup/ || echo "${RED}The directory does not exist${NC}"
  echo "${GREEN}Creating the remote state storage account and container${NC}"
  terraform init;
  terraform apply;
  if [ $? == 1 ]
  then
      echo "${PUR}The terraform apply for backend storage state has been cancelled, Hence we are not continuing with the next steps${NC}"
      exit 0
  else
    echo "${PUR}We are going to create the AKS cluster in 15 seconds, if you would like to stop here press "CTRL+C",If remote state is not created the next terraform init will fail ${NC}"
  fi
  sleep 15;
  echo "${GREEN}Creating the AKS Cluster${NC}"
  cd ../mbmAKS/ || echo "${RED}The directory does not exist${NC}"
  terraform init;
  terraform apply;
}

# To destroy the infra manually by explicitly giving "Yes"
destroy(){
  cd mbmAKS/ || echo "${RED}The directory does not exist${NC}"
  echo "${RED}Destroying the AKS Cluster${NC}"
  terraform destroy;
  if [ $? == 1 ]
  then
      echo "${PUR}The terraform destroy for AKS Cluster has been cancelled, Hence we are not continuing with the next steps${NC}"
      exit 0
  else
    echo "${RED}Destroying the remote state storage account and container${NC}"
  fi
  sleep 15;
  cd ../mbmRemoteStateSetup/ || echo "${RED}The directory does not exist${NC}"
  terraform destroy;
}

# To Crete the infrastructure automatically without giving "yes"
autoapply(){

  cd mbmRemoteStateSetup/ || echo "${RED}The directory does not exist${NC}"
  echo "${GREEN}Creating the remote state storage account and container${NC}"
  terraform init;
  terraform apply --auto-approve;
  echo "${PUR}We are going to create the AKS cluster in 15 seconds, if you would like to stop here press "CTRL+C",If remote state is not created the next terraform init will fail ${NC}"
  sleep 15;
  echo "${GREEN}Creating the AKS Cluster${NC}"
  cd ../mbmAKS/ || echo "${RED}he directory does not exist${NC}"
  terraform init;
  terraform apply --auto-approve;
}

# To destroy the infra automatically without giving "yes"
autodestroy(){
  echo "${YELLOW} Warning ! The cluster's tfstate is stored remotely,If you are executing this without a valid cluster and storage container, terraform init will fail${NC}"
  printf "%s " "Press Enter to continue"
  read -r
  cd mbmAKS/ || echo "${RED}The directory does not exist${NC}"
  echo "${RED}Destroying the AKS Cluster${NC}"
  terraform destroy --auto-approve;
  echo "${PUR}We are going to destroy the Storage Account in 15 seconds, if you would like to stop here press "CTRL+C" ${NC}"
  sleep 15;
  echo "${RED}Destroying the remote state storage account and container${NC}"
  cd ../mbmRemoteStateSetup/ || echo "${RED}The directory does not exist${NC}"
  terraform destroy --auto-approve;
}

# Check the Create or Destroy

if [ "$1" = "apply" ] ; then
    apply
elif [ "$1" = "destroy" ] ; then
    destroy
elif [ "$1" = "autoapply" ] ; then
    autoapply
elif [ "$1" = "autodestroy" ] ; then
    autodestroy
else
  echo "Please give one of the options [ apply || autoapply || destroy || autodestroy ]"
fi



