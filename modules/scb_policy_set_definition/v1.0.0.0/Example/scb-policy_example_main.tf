#-------------------------------------------
#    Policy Set Definition module
#------------------------------------------
module "SCB-policy-set-definition1" {
  # Local use
  source = "../"


  display_name                = null
  name                        = "Deploy-MDFC-Config"
  policySetDefinitionJsonFile = "policy_set_definition_es_deploy_mdfc_config.tmpl.json"
  management_group_id         = "/providers/Microsoft.Management/managementGroups/test"
}