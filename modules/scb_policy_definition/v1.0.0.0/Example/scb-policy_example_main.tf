#-------------------------------------------
#    Policy Definition module
#------------------------------------------
module "scb-policy-definition1" {
  # Local use
  source = "../"


  # Required variable
  policyDefinitionJsonFile = "Resource_Group_Tags.json"

  # Optional variables
  name         = "Resource_Group_Tags"
  display_name = "Resource_Group_Tags"
}
module "scb-policy-definition2" {
  # Local use
  source = "../"

  # Required variable
  policyDefinitionJsonFile = "Resource_Group_Tags.json"

  # Optional variables
  name                = "Resource_Group_Tags_mgmt"
  display_name        = "Resource_Group_Tags_mgmt"
  management_group_id = "/providers/Microsoft.Management/managementGroups/test"

}