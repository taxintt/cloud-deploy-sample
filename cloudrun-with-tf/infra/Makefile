ENV := dev

.PHONY: plan
plan: ## run terraform plan
	terraform plan --var-file=./$(ENV).tfvars

.PHONY: apply
apply: ## run terraform apply
	terraform apply --var-file=./$(ENV).tfvars

.PHONY: destroy
destroy: ## run terraform destroy
	terraform destroy --var-file=./$(ENV).tfvars

.PHONY: init
init: ## run terraform init
	terraform init -backend-config=./backend.tfvars -upgrade

.PHONY: format
format: ## run terraform fmt
	terraform fmt --recursive