# AI Gateway policy and product design questions

Questions to settle before the APIM product and policy design for agents, tools and models is fixed. Source: DEV test run (test-results/2026-11-05) and design discussion, 2026-11-10.

| Section | # | Question | Why it matters |
|---|---|---|---|
| 1. Consumers and identity | 1.1 | Which caller types will the gateway serve? | Products and policies are sliced by consumer family. |
| 1. Consumers and identity | 1.2 | What credential does an agent present to APIM? | Decides whether products or app roles carry entitlement. |
| 1. Consumers and identity | 1.3 | Do we accept keys at all in UAT/PROD, or identity only? | Keys are shared secrets; identity gives attribution and revocation. |
| 1. Consumers and identity | 1.4 | Which identity does APIM use to reach Foundry? | The model account should trust only the gateway. |
| 1. Consumers and identity | 1.5 | How do applications and channels authenticate when they call an agent API? | The agent API is the public face; end users must be known. |
| 1. Consumers and identity | 1.6 | Where does the end user's identity travel? | Needed for OBO on tools and for per-user accounting, but must not become the model credential. |
| 1. Consumers and identity | 1.7 | Is OBO in scope for the first release? | Changes the tool path and the Entra blueprint setup, not the model path. |
| 1. Consumers and identity | 1.8 | Can prompt agents (run by Foundry) follow the APIM-only rule? | Their model calls happen inside Foundry and cannot be routed. |
| 2. Access tiers and products | 2.1 | Do we use products at all once access is identity based? | Products cannot bind to an identity; they only group rules. |
| 2. Access tiers and products | 2.2 | What are the access tiers, and which APIs sit in each? | Each tier becomes one product and one app role. |
| 2. Access tiers and products | 2.3 | How is an API classified into a tier? | Keeps the catalogue consistent as APIs are added. |
| 2. Access tiers and products | 2.4 | May one API sit in more than one product? | Needed when humans and agents share the model API; open products associate ambiguously. |
| 2. Access tiers and products | 2.5 | Which rules live at product level versus API level? | Identity checks must run on every path; limits are per tier. |
| 2. Access tiers and products | 2.6 | Do products need publishing to the developer portal? | Agent products should be invisible to humans. |
| 2. Access tiers and products | 2.7 | Which product owns the kill switch check? | The switch must stop both agent invocation and model use. |
| 2. Access tiers and products | 2.8 | Who owns each product? | Needed for approvals and incident contact. |
| 2. Access tiers and products | 2.9 | How many products do we create, and what is the unit of a product: one per consumer family, per access tier, per API, or per team? | The count drives how many policies, app roles and approval paths exist; too few blur tiers, too many duplicate rules. |
| 2. Access tiers and products | 2.10 | Is the model API one API with product policy deciding access, or split into separate APIs per model class? | Decides whether tiering is enforced by API membership or by policy logic. |
| 2. Access tiers and products | 2.11 | Which product do the agent APIs themselves belong to, and do agent-to-agent calls need their own product? | Agents calling agents are a consumer family with different trust from external channels. |
| 2. Access tiers and products | 2.12 | Do products map one-to-one to Entra app roles? | The app registration audit must mirror what APIM enforces. |
| 2. Access tiers and products | 2.13 | Are products split per environment inside one gateway, or does each environment have its own gateway with the same product set? | Mixing environments in one gateway shares blast radius and complicates promotion. |
| 2. Access tiers and products | 2.14 | What is the product naming, id and tagging convention? | Product ids are immutable and referenced by pipeline, app roles and Resource Graph. |
| 2. Access tiers and products | 2.15 | When a new API is published, who assigns its product and how is an API outside any product prevented? | An API in no product is reachable by all-APIs keys or open by default. |
| 2. Access tiers and products | 2.16 | Can a product be changed after agents depend on it, and what is the change process? | Moving an API between products silently changes who can call it. |
| 3. Entitlement lifecycle | 3.1 | Who approves an agent's access to a tier? | This is the control Security wants to own. |
| 3. Entitlement lifecycle | 3.2 | Who performs the grant in Entra? | Decides what permission the pipeline needs. |
| 3. Entitlement lifecycle | 3.3 | Will Security allow the pipeline to hold any Entra write permission? | Determines automatic versus request-based onboarding. |
| 3. Entitlement lifecycle | 3.4 | What granularity of entitlement do we need? | Coarse roles are easy to audit; fine control needs data in APIM. |
| 3. Entitlement lifecycle | 3.5 | How is access revoked, and how fast must it take effect? | Tokens live up to an hour after an assignment is removed. |
| 3. Entitlement lifecycle | 3.6 | What happens to an agent that is deployed but not approved? | Should be visible, not silently working. |
| 3. Entitlement lifecycle | 3.7 | Where is the list of entitled agents viewed and audited? | Auditors need one place. |
| 3. Entitlement lifecycle | 3.8 | Do humans and service identities share the same approval path? | Portal subscriptions use a different flow. |
| 3. Entitlement lifecycle | 3.9 | How are agent identities retired? | Deleting an agent deletes its identity; assignments must not linger. |
| 4. Model governance | 4.1 | Where is the approved-model list defined? | No policy restricts deployments today (TST-006). |
| 4. Model governance | 4.2 | How is per-agent model access expressed? | Products cannot do it; Entra roles are too coarse per deployment. |
| 4. Model governance | 4.3 | Who updates the allow list and how are concurrent pipeline runs handled? | A shared named value edited by many runs needs a conflict rule. |
| 4. Model governance | 4.4 | Does the lookup fail open or fail closed? | A missing entry must not grant access. |
| 4. Model governance | 4.5 | Token limits: per agent, per tier, or both? | Cost control and noisy-neighbour protection. |
| 4. Model governance | 4.6 | How do we fall back between deployments? | Keeps agents running during capacity or outage. |
| 4. Model governance | 4.7 | Which API versions and routes are exposed? | Each route is an attack and cost surface. |
| 4. Model governance | 4.8 | Who owns the content-filter (guardrail) template? | TST-015/016 showed a template defect that needed Security to fix. |
| 4. Model governance | 4.9 | How are new models onboarded? | Must flow through approval, policy and allow list in one change. |
| 5. Tools through the gateway | 5.1 | Must every tool an agent calls go through APIM? | Otherwise tool permission is only as good as the agent code. |
| 5. Tools through the gateway | 5.2 | How are tools classified? | Picks the product and the approval tier. |
| 5. Tools through the gateway | 5.3 | Does a tool call carry the end user? | Needed for OBO and for audit of who asked for the action. |
| 5. Tools through the gateway | 5.4 | Who approves a tool for an agent? | Same question as model access, often a different owner. |
| 5. Tools through the gateway | 5.5 | How is an unapproved tool call denied and logged? | The test expects denial plus log evidence. |
| 5. Tools through the gateway | 5.6 | MCP tools: are they allowed, and through what? | MCP servers are tools with their own auth model. |
| 5. Tools through the gateway | 5.7 | Do tool responses pass through any content control? | Indirect prompt injection arrives through tool output. |
| 6. Policy structure and ownership | 6.1 | Which rules sit at global, product, API and operation scope? | Order of evaluation and blast radius of a change. |
| 6. Policy structure and ownership | 6.2 | Which blocks become policy fragments? | One fix rolls to every include. |
| 6. Policy structure and ownership | 6.3 | Who owns the fragments and shared policies, and in which repo? | Shared policies must not be edited by the agent pipeline. |
| 6. Policy structure and ownership | 6.4 | What does the per-agent API policy template contain? | Keeps per-agent policy small and identical. |
| 6. Policy structure and ownership | 6.5 | How are template upgrades rolled to existing agents? | Agents deployed months ago must not drift. |
| 6. Policy structure and ownership | 6.6 | How does the pipeline change shared data safely? | Named values are shared objects. |
| 7. Observability and evidence | 7.1 | What identifies the agent in every log row? | Subscription names disappear with identity-based access. |
| 7. Observability and evidence | 7.2 | What identifies the end user? | Needed for restricted tools and cost allocation. |
| 7. Observability and evidence | 7.3 | Is there one trace across consumer, APIM, agent, tool and model? | APIM to Foundry is proven (TST-021); tools extend the chain. |
| 7. Observability and evidence | 7.4 | Is prompt and response text stored, and who may read it? | Foundry server-side tracing always stores it (former TST-020). |
| 7. Observability and evidence | 7.5 | Which alerts exist from day one? | None exist and the tester could not create them (TST-023). |
| 7. Observability and evidence | 7.6 | Where is the per-agent dashboard? | Foundry Monitor lacks latency and throttling (TST-022). |
| 7. Observability and evidence | 7.7 | How are denials evidenced? | Auditors ask for the refused call, not the allowed one. |
| 8. Environments and promotion | 8.1 | How are APIM products, fragments and named values promoted? | Policy must be identical across environments except parameters. |

