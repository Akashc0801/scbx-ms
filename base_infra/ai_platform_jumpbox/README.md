# AI Platform jump box (dev)

A Windows jump box and Bastion Developer host for working with the private
Foundry landing zone from inside its virtual network. Separate from the
Foundry stack, with its own state (`scb-ai-platform-jumpbox.tfstate`) and
resource group, so it can be destroyed independently.

| Resource | Name | Notes |
| --- | --- | --- |
| Resource group | `az-rg-dtx-aiplatform-jumpbox-dev-001` | |
| Bastion | `az-bas-dtx-aiplatform-jumpbox-dev-001` | Developer SKU: free, shared pool, no AzureBastionSubnet or public IP, one connection at a time |
| VM | `az-vm-dtx-aiplatform-jumpbox-dev-001` | Windows Server 2022, computer name `aifjumpbox01`, NIC in `az-snet-dtx-aiplatform-build-dev-001`, no public IP |
| Shutdown schedule | nightly | 20:00 SE Asia Standard Time |
| Run command | `edge-foundry-policy` | Edge policy for the Foundry portal (see below) |

## Connect

1. Get the password: `terraform output -raw jumpbox_admin_password` (user `aifadmin`).
2. Azure portal → VM → **Connect → Bastion** → authentication type **VM Password**.
3. In Edge on the VM, open `https://ai.azure.com` and sign in with your Entra account.
   You need **Foundry User** on the project (set in the Foundry stack).

## Edge local network access

The Foundry portal is a public site that calls the project over its private
endpoint (10.0.5.x). Edge blocks such background calls from public sites to
private addresses unless the site is allowed, and the portal then shows
"Your request for data was not sent". `scripts/edge-foundry-policy.ps1` sets
`LocalNetworkAccessAllowedForUrls` (and the older
`InsecurePrivateNetworkRequestsAllowedForUrls`) for `https://ai.azure.com`.
Restart Edge after the policy is applied.

## Network requirements

- Firewall application rule `allow-jumpbox-portals` in
  `base_infra/ai_platform_network` lets the build subnet reach the Azure and
  Foundry portals, Microsoft Entra sign-in, Windows Update and Python/GitHub
  packages.
- The private DNS zones linked to the Foundry VNet resolve Foundry, Search,
  Cosmos DB, Storage and Key Vault to their private endpoints.

## VM size

D, B and E-series sizes are `NotAvailableForSubscription` in Southeast Asia for
scbx-testing (checked 2026-10-08), so the VM uses `Standard_DC2ds_v3`
(2 vCPU, 16 GB), which is offered in zone 2 only. Change `jumpbox.sku_size` and
`jumpbox.zone` in `variables.tfvars` where other sizes are available.

## Local commands

```shell
terraform init -backend-config=...   # same backend as the other stacks, key scb-ai-platform-jumpbox.tfstate
terraform plan -var-file=variables.tfvars -out=jumpbox.tfplan
terraform apply jumpbox.tfplan
```
