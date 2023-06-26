# GroomInfra_TEST!!
This is Terraform Provisioning Test Repo

## Tech Stack
<div align="center">
	<img src="https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=Terraform&logoColor=white" />
	<img src="https://img.shields.io/badge/gnubash-E34F26?style=flat&logo=gnubash&logoColor=white" />
</div>

## Provisioning Step - 에러 수정 중
1. terraform init
2. .terraform/modules/vpc/main.tf line 1013 (vpc = true -> domain = "vpc") - fixed resquired
3. .terraform/modules/vpc/main.tf line 35 - annotation required
4. .terraform/modules/vpc/main.tf line 36 - annotation required
5. .terraform/modules/vpc/main.tf line 1246 - annotation required

## Module 수정
1. .terraform/modules/eks/main.tf line 389 에 resolve_conflicts_on_create = try(each.value.resolve_conflicts_resolve_conflicts_on_create, "OVERWRITE") 수정
2. .terraform/modules/eks/main.tf line 390 에 resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE") 추가
  
