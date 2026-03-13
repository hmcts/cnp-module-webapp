---
name: terraform-test
description: Acts as a Terraform QA that generates or updates Terraform tests for modules and resources in a given codebase. It uses the native Terraform testing framework.
---

## Additional reading

- https://developer.hashicorp.com/terraform/language/tests

# Terraform Test - Agent Skill

This skill generates or updates Terraform tests for modules and resources in a given codebase.

## Compatibility

- **Minimum Terraform version: 1.6** — The native Terraform testing framework (`terraform test`) was introduced in Terraform 1.6. This skill does not support earlier versions.
- **Mock providers require Terraform 1.7+** — `mock_provider` and `override_module` blocks were introduced in Terraform 1.7. Tests generated for modules using Terraform < 1.7 must not use mock providers.

## When to use this skill

- The user asks you to generate tests for a Terraform module or resource.
- The user asks you to update existing Terraform tests for a module or resource.
- The user asks you to review existing Terraform tests for completeness or best practices.
- The user asks you to identify gaps in test coverage for a Terraform module or resource.

## Required Tooling

- [Azure MCP server](https://github.com/microsoft/mcp/blob/main/servers/Azure.Mcp.Server/README.md#-azure-mcp-server-)
- [Terraform MCP server](https://github.com/hashicorp/terraform-mcp-server#-terraform-mcp-server)

## Instructions

1. **Normalize the request**
   - Summarize the test generation/update/review scope in one sentence.
   - If scope is ambiguous (repo-wide vs folder/file), default to repo-wide.

2. **Check Terraform version compatibility**
   - Look for a `required_version` constraint in any `terraform {}` block across the `.tf` files.
   - Parse the constraint to determine the minimum version it permits.
   - The version may also be specified in a `.terraform-version` file'; Check here too.
   - If no `required_version` is defined, warn the user that the Terraform version could not be determined and proceed with caution, defaulting to no mock providers.
   - If the minimum permitted version is **below 1.6**, output the following message and **stop immediately** — do not generate any tests:
     > ❌ This skill requires Terraform 1.6 or later. The `required_version` constraint in this module permits versions below 1.6. Please update the constraint to `>= 1.6` before generating tests.
   - Record whether mock providers are supported: they are only available when the minimum permitted version is **1.7 or above**.

3. **Read the Terraform code**
   - Search all `.tf` and `.tfvars` files for modules, resources, variables, and outputs.
   - For each module/resource, identify its name, type, and key properties.
   - For each variable, identify its name, type, and default value (if any).
   - For each output, identify its name and value.

4. **Read existing tests (if any)**
   - Search for existing test files `*.tftest.hcl` or `.tftest.json`.
   - For each test file, identify which modules/resources it tests and what scenarios it covers.

5. **Identify test gaps**
   - For each module/resource, check if there is at least one test covering it.
   - For each variable, check if there is at least one test covering its different values (default, edge cases).
   - For each output, check if there is at least one test validating its value.

6. **Use the Terraform MCP server to get attribute schemas**
   - For each module/resource, call `mcp_hashicorp_ter_get_provider_details` to get the attribute schema and understand required vs optional properties, and any constraints or defaults.
   - Use this information to inform test case generation, ensuring that required properties are always included and that edge cases for optional properties are covered.

7. **Use the Azure MCP server to get best practices (Azure only)**
   - Only perform this step if Azure resources are present in the Terraform code. Azure resources are identified by resource types prefixed with `azurerm_`, `azuread_`, or `azurestack_`, or by provider blocks using `hashicorp/azurerm`, `hashicorp/azuread`, or `hashicorp/azurestack`.
   - If no Azure resources are detected, skip this step entirely.
   - Call `mcp_azure_mcp_get_bestpractices` to get any relevant best practices for the Azure resources being tested.
   - Use this information to inform test case generation, ensuring that best practices are validated in the tests.

8. **Generate or update tests**
   - For each identified gap, generate a new test case in the appropriate test file.
   - If no test file exists for the module/resource, create a new one named `<module/resource>_test.tftest.hcl`.
   - Use the Terraform testing framework syntax to define the test cases, including setup, execution, and validation steps.
   - Ensure that the generated tests are comprehensive, covering happy path scenarios and boundary/negative cases grounded in real schema where applicable.
   - Only use `mock_provider` and `override_module` blocks if mock providers are supported (Terraform >= 1.7). For Terraform 1.6, tests must rely on real provider configurations or `run` blocks with explicit `providers` arguments.

9. **Review and finalize**
   - Review the generated/updated tests for completeness and adherence to best practices.
   - If the user requested a review of existing tests, provide feedback on any gaps or improvements needed.

10. **Output the results**
   - Provide a concise summary of the number of tests generated, updated, or reviewed, and any key findings or recommendations for improving test coverage if applicable.
   - **Always use the Output Schema below to format your response.** Do not deviate from the schema structure.


### Test Case Examples

Use these examples to guide the quality of generated tests. Prefer the patterns shown in the **good** examples and avoid the anti-patterns in the **bad** examples.

---

#### ✅ Good — Descriptive name, specific assertion, helpful error message

```hcl
run "default_location_is_uk_south" {
  command = plan

  assert {
    condition     = azurerm_resource_group.this.location == "UK South"
    error_message = "Expected default location to be 'UK South', got '${azurerm_resource_group.this.location}'"
  }
}
```

---

#### ❌ Bad — Vague name, no meaningful assertion, no error message

```hcl
run "test1" {
  command = plan

  assert {
    condition     = true
    error_message = "failed"
  }
}
```

---

#### ✅ Good — Tests a conditional resource count, covers both branches in separate runs

```hcl
run "alert_created_when_flag_is_false" {
  command = plan

  variables {
    create_alert = false
  }

  assert {
    condition     = length(azurerm_monitor_activity_log_alert.main) == 0
    error_message = "Expected no alerts when create_alert is false, got ${length(azurerm_monitor_activity_log_alert.main)}"
  }
}

run "alert_created_when_flag_is_true" {
  command = plan

  variables {
    create_alert = true
  }

  assert {
    condition     = length(azurerm_monitor_activity_log_alert.main) == 1
    error_message = "Expected one alert when create_alert is true"
  }
}
```

---

#### ❌ Bad — Both branches tested in a single run, making failures ambiguous

```hcl
run "alert_test" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_activity_log_alert.main) >= 0
    error_message = "alert count is wrong"
  }
}
```

---

#### ✅ Good — Validates a computed name using interpolation to match module logic

```hcl
run "name_follows_product_env_convention" {
  command = plan

  variables {
    product = "myapp"
    env     = "dev"
  }

  assert {
    condition     = azurerm_storage_account.this.name == "myappdev"
    error_message = "Expected storage account name 'myappdev', got '${azurerm_storage_account.this.name}'"
  }
}
```

---

#### ❌ Bad — Hardcoded expected value that silently breaks when variables change

```hcl
run "check_name" {
  command = plan

  assert {
    condition     = azurerm_storage_account.this.name == "prodsa"
    error_message = "name is wrong"
  }
}
```

---

#### ✅ Good — Uses `mock_provider` to avoid real credentials (Terraform >= 1.7)

```hcl
mock_provider "azurerm" {}

run "tags_are_applied_to_resource" {
  command = plan

  variables {
    common_tags = {
      environment = "dev"
      product     = "myapp"
    }
  }

  assert {
    condition     = azurerm_resource_group.this.tags["environment"] == "dev"
    error_message = "Expected tag 'environment=dev' to be set on resource group"
  }
}
```

---

#### ❌ Bad — No mock provider, requires live Azure credentials to plan

```hcl
run "check_tags" {
  assert {
    condition     = azurerm_resource_group.this.tags != null
    error_message = "tags missing"
  }
}
```

---

### Output Schema 

> **Conditional sections:** Only include `**Files created:**` if new test files were created. Only include `**Files updated:**` if existing test files were modified. Omit either section entirely if it does not apply.
> For `### Key Findings` and `### Recommendations for Improving Test Coverage`, always include the section heading. If there is nothing to report, output `- None.`

```markdown
  ## Test Summary - <one sentence summary of the test generation/update/review scope>

  | Metric | Count |
  |--------|-------|
  | Tests Generated | <number> |
  | Tests Updated | <number> |
  | Tests Reviewed | <number> |

  **Files created:**
  - `<filename>.tftest.hcl` — <number> run blocks

  **Files updated:**
  - `<filename>.tftest.hcl` — <number> run blocks

  ### Key Findings
  - <brief summary of key findings, or `None.` if not applicable>

  ### Test Coverage
  | Area | Scenarios |
  |------|-----------|
  | <resource or variable area> | <comma-separated list of scenarios covered> |

  ### Recommendations for Improving Test Coverage
  - <brief summary of recommendations, or `None.` if not applicable>
  ```

  ### Example Output

  ```markdown
  ## Test Summary - Generated tests for all modules in the `network` folder.

  | Metric | Count |
  |--------|-------|
  | Tests Generated | 10 |
  | Tests Updated | 0 |
  | Tests Reviewed | 0 |

  **Files created:**
  - `network_test.tftest.hcl` — 10 run blocks

  ### Key Findings
  - No existing tests were found for the `network` modules, indicating a gap in test coverage.

  ### Test Coverage
  | Area | Scenarios |
  |------|-----------|
  | `azurerm_virtual_network` | default CIDR, custom CIDR |
  | `var.location` | default value, custom value |

  ### Recommendations for Improving Test Coverage
  - Ensure that all new modules have corresponding tests created as part of the development process to maintain comprehensive test coverage.
  ```