# Terraform Google Cloud Run Function (2nd Gen) - Zip Deployment

This Terraform project deploys a Python Google Cloud Run Function (2nd generation) using a zip file stored in a GCS bucket.

## Architecture

The project creates:
- A GCS bucket to store the function source code
- Archives the function code into a zip file
- Uploads the zip to the bucket
- Deploys a Cloud Functions (2nd gen) using the zip file as source

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- A GCP project with billing enabled
- Required APIs enabled:
  - Cloud Functions API
  - Cloud Build API
  - Cloud Run API
  - Artifact Registry API

## Enable Required APIs

```bash
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

## Project Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example tfvars file
├── env.example                # Example environment variables
├── Makefile                   # Makefile for easy deployment
├── .gitignore                 # Git ignore rules
├── README.md                  # This file
└── function/                  # Python function source code
    ├── main.py               # Function code
    └── requirements.txt      # Python dependencies
```

## Configuration

You can configure this project using either method:

### Option 1: Using .env file (Recommended)

1. Copy the example environment file:

```bash
cp env.example .env
```

2. Edit `.env` with your values:

```bash
TF_VAR_project_id=your-gcp-project-id
TF_VAR_region=us-central1
TF_VAR_function_name=my-python-function
```

**Note:** The Makefile automatically loads variables from `.env`, so you don't need to source it when using `make` commands. If you're using Terraform directly, you'll need to either:
- Add `export` to each line in `.env` and run `source .env`, OR
- Use `terraform.tfvars` instead (see Option 2 below)

### Option 2: Using terraform.tfvars

1. Copy the example tfvars file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:

```hcl
project_id    = "your-gcp-project-id"
region        = "us-central1"
function_name = "my-python-function"
```

## Usage

### Using Make (Recommended)

The Makefile provides convenient commands for common operations:

```bash
# Show all available commands
make help

# Setup project (enable APIs and initialize Terraform)
make setup

# Deploy resources
make deploy

# Test the deployed function
make test-function

# View function logs
make logs

# Destroy resources
make destroy

# Clean up local files
make clean
```

### Using Terraform Directly

If you want to use Terraform commands directly instead of Make, use `terraform.tfvars` for configuration (see Option 2 above).

#### Initialize Terraform

```bash
terraform init
```

#### Plan Deployment

```bash
terraform plan
```

#### Deploy

```bash
terraform apply
```

#### Test the Function

After deployment, use the output URL to test:

```bash
# Get the function URL
FUNCTION_URL=$(terraform output -raw function_url)

# Test with GET request
curl "${FUNCTION_URL}"

# Test with name parameter
curl "${FUNCTION_URL}?name=Terraform"

# Test with POST request
curl -X POST "${FUNCTION_URL}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Cloud Functions"}'
```

### Destroy Resources

```bash
terraform destroy
```

## Customization

### Variables

Key variables you can customize in `terraform.tfvars`:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP project ID | Required |
| `region` | Deployment region | `us-central1` |
| `function_name` | Function name | `python-http-function` |
| `runtime` | Python runtime version | `python312` |
| `entry_point` | Function entry point | `hello_http` |
| `max_instance_count` | Max instances | `3` |
| `min_instance_count` | Min instances | `0` |
| `available_memory` | Memory allocation | `256M` |
| `timeout_seconds` | Function timeout | `60` |
| `allow_unauthenticated` | Allow public access | `true` |

### Modify the Function

Edit `function/main.py` to change the function logic. The function uses the Functions Framework and receives HTTP requests.

### Add Dependencies

Add Python packages to `function/requirements.txt`.

### Environment Variables

Pass environment variables to your function:

```hcl
environment_variables = {
  API_KEY = "your-api-key"
  ENV     = "production"
}
```

## Security Considerations

- By default, the function allows unauthenticated access (`allow_unauthenticated = true`)
- To require authentication, set `allow_unauthenticated = false` in your tfvars
- Consider using a custom service account with minimal permissions
- The bucket has a lifecycle rule to delete old zip files after 30 days

## Cost Management

**Important:** To avoid ongoing charges, destroy the resources when you're done testing:

```bash
make destroy
```

This will remove:
- The Cloud Function
- The GCS bucket and all stored files
- All associated infrastructure

Cloud Functions incur charges based on:
- Number of invocations
- Compute time (GB-seconds)
- Egress traffic

Even with minimal traffic, leaving resources deployed will result in charges. Always clean up test deployments.

## Outputs

After deployment, the following outputs are available:

- `function_url` - The HTTPS URL to invoke the function
- `function_name` - The deployed function name
- `function_location` - The function's region
- `bucket_name` - The GCS bucket storing the source code
- `bucket_url` - The GCS bucket URL

## Troubleshooting

### Permission Errors

Ensure your GCP account has the required permissions:

```bash
gcloud auth application-default login
```

### API Not Enabled

If you see API errors, enable required APIs:

```bash
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com run.googleapis.com artifactregistry.googleapis.com
```

### Function Build Failures

Check Cloud Build logs:

```bash
gcloud builds list --limit=5
gcloud builds log <BUILD_ID>
```

## References

- [Terraform Google Cloud Functions Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions2_function)
- [Google Cloud Functions Terraform Tutorial](https://cloud.google.com/functions/docs/tutorials/terraform)
- [Cloud Functions 2nd Gen Documentation](https://cloud.google.com/functions/docs/2nd-gen/overview)

## License

This project is provided as-is for educational purposes.
