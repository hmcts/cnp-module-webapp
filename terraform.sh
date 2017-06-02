!/usr/bin/env bash

state_store_resource_group="contino-moj-tf-state"
state_store_storage_acccount="continomojtfstate"
bootstrap_state_storage_container="contino-moj-tfstate-container"

terraform init \
    -backend-config "storage_account_name=$state_store_storage_acccount" \
    -backend-config "container_name=$bootstrap_state_storage_container" \
    -backend-config "resource_group_name=$state_store_resource_group"

terraform "$@"