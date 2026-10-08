# AIGW and Foundry dev network

This Terraform stack provisions the dev network foundation through the
repository's reusable SCB modules. It follows the structure of
`base_infra/network`: every resource has its own block in `variables.tfvars`
carrying the naming-module inputs and tags, and `main.tf` passes them to the
modules with `for_each`.

| File | Purpose |
| --- | --- |
| `main.tf` | Resource group, NSG, VNet, route-table, private DNS, public IP, firewall policy, and firewall module calls |
| `variables.tf` | Typed input variables |
| `variables.tfvars` | One block per resource |
| `outputs.tf` | Names and IDs keyed by resource key |

## Resources

| Resource | AIGW | Foundry |
| --- | --- | --- |
| Resource group | `az-rg-dtx-aiplatform-aigw-dev-001` (`aigw_rg`) | `az-rg-dtx-aiplatform-foundry-dev-001` (`foundry_rg`) |
| VNet | `az-vnet-dtx-aiplatform-aigw-dev-001` (`10.0.0.0/22`) | `az-vnet-dtx-aiplatform-foundry-dev-001` (`10.0.4.0/22`) |
| Subnets | `az-snet-dtx-aiplatform-apim-dev-001` (`10.0.0.0/24`), `az-snet-dtx-aiplatform-pe-dev-001` (`10.0.1.0/26`), `az-snet-dtx-aiplatform-logicapp-dev-001` (`10.0.1.64/26`) | `az-snet-dtx-aiplatform-foundryagent-dev-001` (`10.0.4.0/24`), `az-snet-dtx-aiplatform-foundrype-dev-001` (`10.0.5.0/26`), `az-snet-dtx-aiplatform-build-dev-001` (`10.0.5.64/27`) |
| NSGs | One per subnet: `aigw_apim_nsg`, `aigw_pe_nsg`, `aigw_logicapp_nsg` | One per subnet: `foundry_agent_nsg`, `foundry_foundrype_nsg`, `foundry_build_nsg` |
| Route table | `aigw_route_table`, associated with all three subnets | `foundry_route_table`, associated with all three subnets |

Each route table sends `0.0.0.0/0` to the AIGW Azure Firewall private IP using
next hop `VirtualAppliance`. The AIGW and Foundry VNets are peered in both
directions with forwarded traffic enabled so Foundry can reach the firewall.
No custom NSG rules are defined; `security_rules` stays empty until rules are
approved.

## Firewall (AIGW)

| Resource | Key | Deployed name |
| --- | --- | --- |
| Firewall policy | `aigw_firewall_policy` | `az-fwp-dtx-aiplatform-aigw-dev-001` |
| Firewall | `aigw_firewall` | `az-afw-dtx-aiplatform-aigw-dev-001` |
| Public IP | `aigw_firewall_pip` | `az-pip-dtx-aiplatform-aigw-dev-afw-001` |
| Subnet | `firewall` in `aigw_vnet` | `AzureFirewallSubnet` (`10.0.1.128/26`, name mandated by Azure) |

All are created in `az-rg-dtx-aiplatform-aigw-dev-001` using the workload
naming format. The firewall is `AZFW_VNet` / `Standard` and uses the policy
(`Standard`, threat intelligence `Deny`, DNS proxy enabled). The firewall
subnet has no NSG or route table.

| VNet peering | Name |
| --- | --- |
| AIGW to Foundry | `az-peer-dtx-aiplatform-aigw-to-foundry-dev-001` |
| Foundry to AIGW | `az-peer-dtx-aiplatform-foundry-to-aigw-dev-001` |

## Firewall rules (AIGW)

Rule collection group `az-rcg-dtx-aiplatform-aigw-dev-001` (priority 200) is
attached to `aigw_firewall_policy`. It holds placeholder rules only; replace
them with approved rules before production use.

| Collection | Priority | Dummy rule |
| --- | --- | --- |
| `az-nrc-dtx-aiplatform-aigw-dev-001` (network, Allow) | 1000 | `dummy-allow-aigw-to-foundry-https`: TCP 443 from `10.0.0.0/22` to `10.0.4.0/22` |
| `az-arc-dtx-aiplatform-aigw-dev-001` (application, Allow) | 2000 | `dummy-allow-microsoft-https`: HTTPS 443 from `10.0.0.0/22` and `10.0.4.0/22` to `www.microsoft.com` |

## Private DNS resolver (AIGW)

| Resource | Name | Subnet |
| --- | --- | --- |
| Resolver (`aigw_dns_resolver`) | `az-dnspr-dtx-aiplatform-aigw-dev-001` | `aigw_vnet` |
| Inbound endpoint | `az-in-dtx-aiplatform-aigw-dev-001` | `az-snet-dtx-aiplatform-dnsin-dev-001` (`10.0.1.192/28`) |
| Outbound endpoint | `az-out-dtx-aiplatform-aigw-dev-001` | `az-snet-dtx-aiplatform-dnsout-dev-001` (`10.0.1.208/28`) |

Both subnets are delegated to `Microsoft.Network/dnsResolvers`, with no NSG or
route table. The `scb_dnsresolver` module does not use the naming module, so the
names are set explicitly in `variables.tfvars`. No forwarding ruleset is defined
yet, so the outbound endpoint forwards nothing until one is added.

## Naming

Resource groups, VNets, NSGs, and route tables opt into the SCB naming module's `workload` format:
`org-type-app_code-base_name-env-iterator`. Their inputs are `org = "az"`,
`app_code = "dtx-aiplatform"`, `env = "dev"`, and `iterator = "001"`.
`region_code` is omitted so no region is included in the name;
`location_region_code = "sea"` retains the existing Southeast Asia location.
The Foundry resource group uses the corrected `aiplatform` spelling.

NSGs use `az-nsg-dtx-aiplatform-<subnet-base>-dev-001`, with bases `apim`,
`pe`, `logicapp`, `foundryagent`, `foundrype`, and `build`. Route tables use
`az-rt-dtx-aiplatform-aigw-dev-001` and
`az-rt-dtx-aiplatform-foundry-dev-001`. These resources use the `DEV`
environment tag. Other callers retain the default `legacy` naming format.
Subnet names are set explicitly in `variables.tfvars`, as in `base_infra/network`.
All six subnet names follow the requested workload convention.
Resource keys, CIDRs, NSG references, and route-table associations are unchanged.

Changing names of existing Azure resources can require replacement. Review the
Terraform plan before applying. The location (`sea`) remains an assumption.

## Values to complete

`variables.tfvars` sets `au = "12345"` and `app_support = "abc@xyz.com"`.
All resource statuses are `Live`, and private DNS environment tags are `DEV`.
Other unknown values (`bu`, `owner`, ownership and business tags, and so on)
remain blank. Confirm the configured values and complete required metadata
before planning or applying:

- `au`: numeric accounting unit.
- `app_support`: a valid email address (validated for resource groups and
  private DNS zones).

The configured AU and support email satisfy the numeric and email formats.
Static `terraform validate` does not replace a successful Terraform plan or
verification of Azure permissions and policy compliance.

Complete the required values and review the plan before merging to `main`.

## GitHub Actions

`.github/workflows/deployment.yml` performs Terraform formatting, backend-free
initialization and validation, Checkov scanning, an OIDC-authenticated
remote-state plan, and an apply of the exact saved plan. Apply runs only for
pushes to `main` or manual runs on `main`, after validation, Checkov scanning,
and planning pass. Apply is automatic; no verification flag or GitHub
Environment approval gate is used.

Pull requests targeting `main` and pushes to `main` trigger the workflow only
when `.github/workflows/deployment.yml`, `base_infra/ai_platform_network/**`,
or `modules/**` changes. The module filter includes nested and shared module
dependencies. Manual runs remain available regardless of changed paths.

All pull requests run formatting, backend-free initialization and validation,
and Checkov only. Azure login, remote-state initialization, planning, and plan
artifact upload are skipped on pull requests, including same-repository PRs.
Push and manual events run the remote-state plan after validation succeeds.

Configure these repository-level GitHub Actions secrets so both plan and apply
can access them:

| Secret | Purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | Entra application/client ID with GitHub workload identity federation |
| `AZURE_TENANT_ID` | Entra tenant ID |

The workflow sets `ARM_SUBSCRIPTION_ID` directly to
`3471ad5a-d8a8-4a80-b30b-668798733c14`. Both Azure login steps use the same
`ARM_*` values as Terraform.

The workflow defines the remote backend directly; no `TF_BACKEND_*` GitHub
Actions variables are required:

| Backend setting | Value |
| --- | --- |
| `resource_group_name` | `rg-scbx-terraform-state` |
| `storage_account_name` | `stscbxtf3471ad5a` |
| `container_name` | `tfstate` |
| `key` | `scb-ai-platform-network.tfstate` |
| `use_azuread_auth` | `true` |
| `use_oidc` | `true` |

This network stack uses a separate state key from the policy deployment.
Changing the key does not migrate existing state; if this stack was already
applied using another key, review and migrate its state before applying again.

Configure Entra federated credentials with issuer
`https://token.actions.githubusercontent.com` and audience
`api://AzureADTokenExchange`. This repository uses GitHub immutable subjects,
which include the owner and repository IDs:

| Job context | Federated credential subject |
| --- | --- |
| Plan and apply on `main` pushes or manual runs | `repo:Akashc0801@125369880/scbx-ms@1405194317:ref:refs/heads/main` |

The subject must match exactly; the plain-name subject without numeric IDs
does not match this repository's tokens. Manual plans on other branches require
corresponding branch subjects. Pull requests do not request Azure OIDC tokens
and do not require a pull-request federated credential for this workflow.

Grant the identity only the
permissions needed for resource-group and network management, and grant
`Storage Blob Data Contributor` on the state container. Both plan and apply
use repository-level secrets and branch-based OIDC on `main`; an environment
federated credential alone is not sufficient.
The workflow uses OIDC and Azure AD backend authentication; it does not use
client secrets or storage account keys.

## Local validation

From this folder:

```shell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

The remote backend and Azure plan/apply are used only in the configured
workflow.
