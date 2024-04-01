# Infrastructure Provisioning

## Setup ssh key pair to connect other virtual machines

```shell
ssh-keygen -t rsa -b 4096 -f ./id_vm
```

## Create Azure resources with Terraform
### Terraform `plan`

```terraform
terraform plan -var-file=local.tfvars
```


### Terraform `apply`
```terraform
terraform apply -auto-approve -var-file=local.tfvars
```


## Clean up Azure resources

```terraform
terraform destroy -auto-approve -var-file=local.tfvars
```