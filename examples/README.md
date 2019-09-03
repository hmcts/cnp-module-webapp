# Example CNP-Module-WebApp

## Description

This is an example implementation of the module that should be used for reference and local testing.

## Usage

```bash
terraform plan -var "subscription_id=<id>" \
               -var "subscription=<name>" \
               -out=plan.tfplan

terraform apply plan.tfplan

terraform destroy -var "subscription_id=<id>" \
                  -var "subscription=<name>"
```