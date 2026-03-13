# Terraform Test — Agent Skill

This agent skill generates, updates, and reviews native Terraform tests for modules and resources using the Terraform testing framework (`terraform test`). The skill is cloud-agnostic and works with any Terraform module, with additional Azure-specific guidance applied automatically when Azure resources are detected.

## What It Does

When you ask Copilot to generate Terraform tests, this skill:

1. Checks the Terraform version compatibility of the module (requires >= 1.6)
2. Scans all `.tf` and `.tfvars` files for modules, resources, variables, and outputs
3. Reads any existing test files and identifies coverage gaps
4. Calls the Terraform MCP server to fetch provider attribute schemas
5. Calls Azure best-practice guidance to inform test case generation (Azure modules only)
6. Generates or updates `.tftest.hcl` test files with comprehensive plan-mode tests
7. Uses `mock_provider` and `override_module` blocks where supported (Terraform >= 1.7)
8. Returns a structured test summary report

## Prerequisites

- GitHub Copilot with agent mode enabled in VS Code
- Terraform MCP tools available in the coding session
- Azure MCP tools available in the coding session _(only required for modules containing Azure resources)_
- Terraform >= 1.6 configured in the target module

## Usage

Open this repository in VS Code, switch Copilot to **Agent** mode, and prompt it. Example prompts:

- "Use the terraform-test skill to generate tests for this module"
- "Generate Terraform tests for the application-insights module"
- "Review the existing Terraform tests and identify any coverage gaps"
- "Update the tests to cover the new variables added to this module"

## Compatibility

| Feature                             | Minimum Terraform Version |
| ----------------------------------- | ------------------------- |
| `terraform test` framework          | 1.6                       |
| `mock_provider` / `override_module` | 1.7                       |

If the module's `required_version` constraint permits versions below 1.6, the skill will stop and ask you to update the constraint before proceeding.

## Output Format

The skill outputs:

- `Test Summary` — one-sentence scope description
- Metrics table — tests generated, updated, and reviewed
- `Key Findings` — notable issues discovered (e.g. bugs uncovered by tests)
- `Test Coverage` table — areas covered and scenarios tested
- `Recommendations for Improving Test Coverage`

## Files

```text
.github/skills/terraform-test/
  SKILL.md    # Copilot instructions for test generation workflow
  README.md   # This file
```
