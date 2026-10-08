# AI Platform Foundry landing zone (dev)

This Terraform stack deploys the Microsoft Foundry landing zone (build sheet
`04_Foundry_Resources`, FD-N-001..008) through the repository's SCB modules. It
deploys into the resource group, VNet, subnets and private DNS zones created by
`base_infra/ai_platform_network`, which it looks up by name, and keeps its own
state.

| File | Purpose |
| --- | --- |
| `main.tf` | Module calls |
| `locals.tf` | Connections, role assignments, capability hosts and expected names |
| `data.tf` | Lookups of network-stack resources |
| `checks.tf` | Plan-time guards (name lengths, agent subnet delegation, identity keys) |
| `variables.tf` | Typed input variables |
| `variables.tfvars` | Values; `common` holds naming inputs and tags shared by every resource |
| `outputs.tf` | Names and IDs |
| `tests/plan.tftest.hcl` | Full-stack plan against mocked providers |

## Resources

| Build sheet | Resource | Module | Generated name |
| --- | --- | --- | --- |
| FD-N-001 | Foundry account (agent network injection, private endpoint, local auth off, public access off) | `scb_ms_ai_foundry/v1.0.0.2` | `az-aif-dtx-aiplatform-foundry-dev-001` |
| FD-N-002 | Foundry project per use case, with Cosmos DB, Storage, AI Search and App Insights connections and a capability host | `scb_ms_ai_foundry/v1.0.0.2` | project key, e.g. `usecase-001` |
| FD-N-003 | Key Vault | `scb_key_vault/v1.0.0.3` | `az-kv-dtx-aip-fd-dev-001` |
| FD-N-004 | Storage account (blob and file private endpoints, shared keys off) | `scb_storage_account/v1.0.0.1` | `azstdtxaipfoundrydev001` |
| FD-N-005 | Cosmos DB for NoSQL (serverless, continuous backup) | `scb_cosmosdb_account/v1.0.0.1` | `az-cosmos-dtx-aiplatform-foundry-dev-001` |
| FD-N-006 | AI Search | `scb_ai_search/v1.0.0.1` | `az-srch-dtx-aiplatform-foundry-dev-001` |
| FD-N-007 | Container registry (Premium) | `scb_azure_container_registry/v1.0.0.0` | `azacrdtxaiplatformfoundrydev001` |
| FD-N-008 | Application Insights (workspace-based) | `scb_app_insights/v1.0.0.1` | `az-appi-dtx-aiplatform-foundry-dev-001` |
| — | Log Analytics workspace | `scb_log_analytics_workspace/v1.0.0.1` | `az-log-dtx-aiplatform-foundry-dev-001` |
| — | User-assigned identities (Foundry account, one per project) | `scb_user_managed_identity/v1.0.0.1` | `az-id-dtx-aiplatform-<base>-dev-001` |
| RBAC-006 | Project developer group roles | `scb_role_assignments/v1.0.0.0` | — |

Every resource sends diagnostics to the Log Analytics workspace and gets the
`resource_lock` (CanNotDelete by default).

## Standard agent setup

Each project uses a user-assigned identity so its principal ID is known at
plan time. The Foundry module then:

1. Grants the project identity Cosmos DB Operator, Storage Blob Data
   Contributor, Search Index Data Contributor and Search Service Contributor.
2. Creates the project connections and the project capability host
   (thread storage: Cosmos DB, file storage: Storage, vector store: AI Search).
3. Grants Cosmos DB Built-in Data Contributor on the `enterprise_memory`
   database and Storage Blob Data Owner limited (ABAC) to the project's agent
   containers.

## Naming

Names come from `scb_naming_module/v1.0.0.1` in the `workload` format used by
`base_infra/ai_platform_network`: `org-type-app_code-base_name-env-iterator`
with `org = "az"`, `app_code = "dtx-aiplatform"`, `env = "dev"`, no region in
the name and `location_region_code = "sea"` for the location. `common` can
switch to `naming_format = "legacy"` and set `region_code`.

The naming module does not apply `max_length` unless `add_random` is true, so
`checks.tf` fails the plan if a generated name exceeds the Azure limit. Key
Vault and Storage use `app_code = "dtx-aip"` to stay within 24 characters.

## Prerequisites in `base_infra/ai_platform_network`

- The agent subnet must be delegated to `Microsoft.App/environments`
  (checked at plan).
- The private DNS zones listed in `locals.tf` must exist in
  `network.private_dns_zone_resource_group_name`.

## Values to complete

Blank values in `variables.tfvars` (owner and tag values, project developer
group object
IDs. `au = "12345"` and `app_support = "abc@xyz.com"` are the placeholders
used by the network stack. Model deployments are left empty until the approved
model list and deployment type are confirmed.

## Local validation

```shell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test -var-file=variables.tfvars
```
