# Two-Tier Web Server / Database on AWS

Using Terraform, the files in this folder setup a two-tier architecture on AWS. It has an Apache webserver on Amazon 64bit linux running on a T2 micro EC2 instance. For the back tier it uses RDS as the DB. It sets up an appropriate security group and is an example of using variables and tests to make sure your infrastructure was deployed.  

# First Time Initializing (Do this once)
Assumes you have admin locally and a valid AWS IAM account with EC2 access and you have a valid key and private key.

Install Terraform (example command is for OSX w/ brew installed, but Terraform can be directly downloaded [here](https://www.terraform.io/downloads.html))
```bash
brew install terraform
```

Export your AWS IAM key and secret access key into your environment (example assumes bash).
Make sure to change [YOUR_IAM_ACCESS_KEY_ID] and [YOUR_IAM_SECRET_ACCESS_KEY] to your account specifics
```
echo 'export AWS_ACCESS_KEY_ID="[YOUR_IAM_ACCESS_KEY_ID]"' >> ~/.bash_profile
echo `export AWS_SECRET_ACCESS_KEY="[YOUR_IAM_SECRET_ACCESS_KEY]"' >> ~/.bash_profile
source ~/.bash_profile
```

Clone this repo and Initialize Terraform
```
git clone https://github.com/whit1206/terraform-webdb-aws.git
cd terraform-webdb-aws
terraform init
```

# Deploying Your Infrastructure
To deploy our two tier architecture
```
terraform apply
```

# Removing Your Infrastructure
To remove all traces of our two tier architecture
```
terraform destroy
```

# Running Tests
To perform a practice run
```
terraform plan
```
