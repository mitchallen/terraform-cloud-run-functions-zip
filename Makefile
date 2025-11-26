.PHONY: help init plan deploy destroy clean validate fmt check test-function enable-apis

# Load environment variables from .env file if it exists
ifneq (,$(wildcard .env))
    include .env
    export
endif

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	terraform init

validate: ## Validate Terraform configuration
	@echo "Validating Terraform configuration..."
	terraform validate

fmt: ## Format Terraform files
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

plan: ## Plan Terraform changes
	@echo "Planning Terraform changes..."
	terraform plan

deploy: ## Deploy GCP resources
	@echo "Deploying GCP resources..."
	terraform apply -auto-approve
	@echo ""
	@echo "Deployment complete!"
	@echo "Function URL: $$(terraform output -raw function_url)"

destroy: ## Destroy GCP resources
	@echo "Destroying GCP resources..."
	terraform destroy -auto-approve
	@echo "Resources destroyed successfully!"

clean: ## Clean up local Terraform files
	@echo "Cleaning up local Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f function-source.zip
	@echo "Cleanup complete!"

check: validate fmt ## Validate and format Terraform files

enable-apis: ## Enable required GCP APIs
	@echo "Enabling required GCP APIs..."
	@if [ -z "$(TF_VAR_project_id)" ]; then \
		echo "Error: TF_VAR_project_id not set. Please source .env file or set the variable."; \
		exit 1; \
	fi
	gcloud services enable cloudfunctions.googleapis.com --project=$(TF_VAR_project_id)
	gcloud services enable cloudbuild.googleapis.com --project=$(TF_VAR_project_id)
	gcloud services enable run.googleapis.com --project=$(TF_VAR_project_id)
	gcloud services enable artifactregistry.googleapis.com --project=$(TF_VAR_project_id)
	@echo "APIs enabled successfully!"

test-function: ## Test the deployed function
	@echo "Testing the deployed function..."
	@FUNCTION_URL=$$(terraform output -raw function_url 2>/dev/null); \
	if [ -z "$$FUNCTION_URL" ]; then \
		echo "Error: Function not deployed or terraform output not available."; \
		exit 1; \
	fi; \
	echo "Function URL: $$FUNCTION_URL"; \
	echo ""; \
	echo "Test 1: Basic GET request"; \
	curl -s "$$FUNCTION_URL"; \
	echo ""; \
	echo ""; \
	echo "Test 2: GET request with name parameter"; \
	curl -s "$$FUNCTION_URL?name=Terraform"; \
	echo ""; \
	echo ""; \
	echo "Test 3: POST request with JSON"; \
	curl -s -X POST "$$FUNCTION_URL" \
		-H "Content-Type: application/json" \
		-d '{"name": "Cloud Functions"}'; \
	echo ""

setup: enable-apis init ## Setup project (enable APIs and initialize Terraform)
	@echo "Setup complete! You can now run 'make deploy'"

redeploy: destroy deploy ## Destroy and redeploy resources

output: ## Show Terraform outputs
	@terraform output

logs: ## Show Cloud Function logs (requires gcloud)
	@if [ -z "$(TF_VAR_project_id)" ]; then \
		echo "Error: TF_VAR_project_id not set. Please source .env file or set the variable."; \
		exit 1; \
	fi
	@FUNCTION_NAME=$$(terraform output -raw function_name 2>/dev/null); \
	REGION=$$(terraform output -raw function_location 2>/dev/null); \
	if [ -z "$$FUNCTION_NAME" ] || [ -z "$$REGION" ]; then \
		echo "Error: Function not deployed or terraform output not available."; \
		exit 1; \
	fi; \
	echo "Fetching logs for $$FUNCTION_NAME in $$REGION..."; \
	gcloud functions logs read $$FUNCTION_NAME --region=$$REGION --project=$(TF_VAR_project_id) --limit=50
