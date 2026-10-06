#-------------------------------------------
#    Policy Definition module
#------------------------------------------
module "scb_policy_assignment_nprd" {
  source = "../"

  # Required variable
  name                     = "DeployLAWDiag"
  display_name             = "SCB Enterprise Initiative – Monitoring_NPRD"
  policyDefinitionJsonFile = "policy_assignment_es_deploy_resource_diag.tmpl.json"
  policy_definition_id     = "/providers/Microsoft.Management/managementGroups/mg-scb-root/providers/Microsoft.Authorization/policySetDefinitions/SCB Enterprise Initiative – Monitoring"
  not_scopes               = ["/providers/Microsoft.Management/managementGroups/c0ce9cf9-9431-4e43-a2fc-a763d4cb8a66", "/providers/Microsoft.Management/managementGroups/ee81765a-9c2c-4697-95e6-24c083d16b19", "/providers/Microsoft.Management/managementGroups/91fdbcd9-43ae-4f20-acb1-756058024202", "/providers/Microsoft.Management/managementGroups/a0fe583d-e77d-4585-9196-b84411b66b07"]
  location                 = "southeastasia"
  management_group_id      = "/providers/Microsoft.Management/managementGroups/mg-scb-root"
  enforcement_mode         = "false"

}