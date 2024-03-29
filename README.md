# Terraform

Download [terraform](https://releases.hashicorp.com/terraform/0.11.14/)

```bash
unzip terraform.zip
cp terraform /usr/local/bin/terraform
chmod u+x /usr/local/bin/terraform
terraform version
```

## AWS authentication

Please use your crenetials.csv file that you download when create IAM user or generate
new one.
Create file `~/aws_creds.txt` with such content:

```bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

Before start terraform commands please do:

```bash
source ~/aws_creds.txt
```

More info how to authenticate in AWS you can find [here](https://www.terraform.io/docs/providers/aws/index.html#authentication)

## Install awscli

```bash
easy_install pip
pip install awscli
aws configure
```

## Configure and run first project

Before start we need to set ENV variables
```bash
cd simple-ec2-creation
export TF_VAR_vpc_id=$(aws ec2 describe-vpcs --filters "Name=isDefault, Values=true" --query 'Vpcs[*].{id:VpcId}' --output text --region us-east-1)
export TF_VAR_subnet_id=$(aws ec2 describe-subnets --query 'Subnets[0].{id:SubnetId}' --output text --region us-east-1)
export TF_VAR_env=dev
```

```bash
terraform init
terraform plan
terraform apply
```

### Create S3 bucket for storing states

```bash
aws s3api create-bucket --bucket terraform-itea-workshop-<YOUR_NAME> --region us-east-1
```

### Config remote state
```bash
BUCKET_NAME="terraform-itea-workshop-<YOUR_NAME>"
grep -Rl '@@bucket@@' . | xargs sed -i.bac -e 's/@@bucket@@/${BUCKET_NAME}/g' # For MAC
grep -Rl '@@bucket@@' . | xargs sed -i's/@@bucket@@/${BUCKET_NAME}/g' # On Linux
```

### Init terraform with remote state

```bash
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform plan
terraform apply
```

## Base AWS setup with VPCs

```bash
cd base_aws_setup
export TF_VAR_env=prod
grep -Rl '@@bucket@@' . | xargs sed -i.bac -e 's/@@bucket@@/${BUCKET_NAME}/g' # For MAC
grep -Rl '@@bucket@@' . | xargs sed -i's/@@bucket@@/${BUCKET_NAME}/g' # On Linux
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform plan -var-file=environment/${TF_VAR_env}.tfvars
terraform apply -var-file=environment/${TF_VAR_env}.tfvars
```

## ECS cluster creation

```bash
cd ecs-cluster-setup
export TF_VAR_env=dev
grep -Rl '@@bucket@@' . | xargs sed -i.bac -e 's/@@bucket@@/${BUCKET_NAME}/g' # For MAC
grep -Rl '@@bucket@@' . | xargs sed -i's/@@bucket@@/${BUCKET_NAME}/g' # On Linux
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform plan -var-file=environment/${TF_VAR_env}.tfvars
terraform apply -var-file=environment/${TF_VAR_env}.tfvars
```

## Deploy nginx to ECS

```bash
cd ecs-service
export TF_VAR_env=dev
grep -Rl '@@bucket@@' . | xargs sed -i.bac -e 's/@@bucket@@/${BUCKET_NAME}/g' # For MAC
grep -Rl '@@bucket@@' . | xargs sed -i's/@@bucket@@/${BUCKET_NAME}/g' # On Linux
terraform init -backend-config=config/${TF_VAR_env}-state.conf
terraform plan -var-file=environment/${TF_VAR_env}.tfvars
terraform apply -var-file=environment/${TF_VAR_env}.tfvars
```

## Cleanup

```bash
# Delete ecs-service
export TF_VAR_env=dev
cd ecs-service
terraform destroy -var-file=environment/${TF_VAR_env}.tfvars
rm -rf .terraform
# Delete ecs-cluster
export TF_VAR_env=dev
cd ecs-cluster-setup
terraform destroy -var-file=environment/${TF_VAR_env}.tfvars
rm -rf .terraform
# Delete base infra
export TF_VAR_env=prod
cd base_aws_setup
terraform destroy -var-file=environment/${TF_VAR_env}.tfvars
rm -rf .terraform
```
