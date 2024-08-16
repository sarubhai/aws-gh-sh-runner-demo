## AWS GitHub Self-Hosted Runner Demo
This repository demonstrates how to set up a self-hosted GitHub Actions runner on AWS using Terraform. Follow the instructions below to clone the repository, provision AWS resources, and configure the GitHub Actions runner.

### Provision Self-hosted GitHub Runner in AWS using Terraform
- Retrieve the GitHub Runner registration token from:
```
https://github.com/YourGithubOrg/YourGithubRepo/settings/actions/runners/new?arch=x64&os=linux
```
- Set up the terraform.tfvars file in the tf_runner directory:
```
gh_token    = "YourGithubToken"
gh_orgname  = "YourGithubOrg"
gh_reponame = "YourGithubRepo"
```
- In your terminal, navigate to the tf_runner directory and run the following commands to apply the Terraform configuration:
```
cd tf_runner
export AWS_ACCESS_KEY_ID="YourAccessKey"
export AWS_SECRET_ACCESS_KEY="YourSecretKey"
export AWS_REGION="eu-central-1"

terraform apply --auto-approve
```

### Testing GitHub Actions with the Self-hosted Runner
- Set up the following GitHub Repository secrets:
```
AWS_REGION: eu-central-1
AWS_ACCOUNT_ID: 123456789012
ECR_REPO_NAME: backend-api
```
- Make your code changes in the repository for example in app.py & Commit and push the changes to your GitHub repository.
```
git add .
git commit -m "Test Self Hosted Runner"
git push origin main
```

This will trigger a GitHub Actions workflow that uses the self-hosted runner to verify everything is working correctly. This setup allows you to manage and run GitHub Actions workflows on a dedicated, self-hosted runner within your AWS environment.
