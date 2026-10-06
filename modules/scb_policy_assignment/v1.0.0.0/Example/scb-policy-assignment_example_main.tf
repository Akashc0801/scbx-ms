#---------------------------------------------------
# - Assigning policy using Policy Assignment module
#---------------------------------------------------

# Policy Definition Examples
# - Below example showcases policy assignment for built-in policy definition containing role definition Id
module "scb_policy_assignment_1" {
  source = "../"

  name                               = "Azure Cosmos DB key"
  description                        = "This policy enables you to ensure all Azure Cosmos DB accounts disable key based metadata write access."
  display_name                       = "Azure Cosmos DB key based metadata write access should be disabled"
  not_scopes                         = []
  metadata                           = null
  parameters                         = null
  policy_definition_id               = "/providers/Microsoft.Authorization/policyDefinitions/4750c32b-89c0-46af-bfcb-2e4541a818d5"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = "southeastasia"
  assign_identity                    = true
  management_group_set_definition    = null
  management_group_policy_definition = null
}

#- Below example showcases policy assignment for custom policy definition containing role definition Id
module "scb_policy_assignment_2" {
  source = "../"

  name         = "App_Services_PE"
  description  = "This Policy creates the Private DNS Records for App Services Endpoints."
  display_name = "Create App Services PE DNS Record"
  not_scopes   = []
  metadata     = null
  parameters = {
    "privateDnsZoneId" : {
      "value" : "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19/resourceGroups/rg-ncus-test-aksmod-manu-reqs/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    }
  }
  policy_definition_id               = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19/providers/Microsoft.Authorization/policyDefinitions/App_Services_PE_DNS_Record"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = "southeastasia"
  assign_identity                    = true
  management_group_set_definition    = null
  management_group_policy_definition = null
}

#- Below example showcases policy assignment for built-in policy definition without role definition Id
module "scb_policy_assignment_3" {
  source = "../"


  name                               = "Allowed Locations"
  description                        = "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements."
  display_name                       = "Allowed locations for resource groups"
  not_scopes                         = []
  metadata                           = null
  parameters                         = null
  policy_definition_id               = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19/providers/Microsoft.Authorization/policyDefinitions/Allowed Locations"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = "southeastasia"
  assign_identity                    = false
  management_group_set_definition    = null
  management_group_policy_definition = null
}

##########---------------------##########-------------------###########--------------------------#################

# Policy Set definition Examples

# - Below example showcases policy assignment for custom policy set definition created at Management Group level
# - Below example will not run on MSFT tenant

# module "scb_policy_assignment_4" {
#   source = "../"

#   name                 = "Deploy-MDFC-Config"
#   description          = "This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements."
#   display_name         = "Deploy MDFC Config"
#   not_scopes           = []
#   metadata             = null
#   parameters           = null
#   policy_definition_id = "/providers/Microsoft.Management/managementGroups/test/providers/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config_2" 
#   scope                = "/providers/Microsoft.Management/managementGroups/test"                                                                       
#   enforcement_mode     = null
#   location             = null
#   assign_identity      = true
#   management_group_set_definition = "test"
#   management_group_policy_definition = null
# } 

# - Below examples showcase policy assignment for built-in policy set definitions

module "scb_policy_assignment_5" {
  source = "../"


  name                               = "Configure Linux machine"
  description                        = "Monitor and secure your Linux virtual machines, virtual machine scale sets, and Arc machines by deploying the Azure Monitor Agent extension and associating the machines with a specified Data Collection Rule. Deployment will occur on machines with supported OS images (or machines matching the provided list of images) in supported regions."
  display_name                       = "Configure Linux machines to run Azure Monitor Agent and associate them to a Data Collection Rule"
  not_scopes                         = []
  metadata                           = null
  parameters                         = null
  policy_definition_id               = "/providers/Microsoft.Authorization/policySetDefinitions/118f04da-0375-44d1-84e3-0fd9e1849403"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = null
  assign_identity                    = true
  management_group_set_definition    = null
  management_group_policy_definition = null
}

module "scb_policy_assignment_6" {
  source = "../"

  name                               = "Configure Windows VM SetDef"
  description                        = "Configure machines to automatically install the Azure Monitor and Azure Security agents on virtual ma"
  display_name                       = "Configure machines to automatically install the Azure Monitor and Azure Security agents"
  not_scopes                         = []
  metadata                           = null
  parameters                         = null
  policy_definition_id               = "/providers/Microsoft.Authorization/policySetDefinitions/a15f3269-2e10-458c-87a4-d5989e678a73"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = null
  assign_identity                    = true
  management_group_set_definition    = null
  management_group_policy_definition = null
}

module "scb_policy_assignment_7" {
  source = "../"


  name                               = "CIS Microsoft Benchmark"
  description                        = "This initiative includes policies that address a subset of CIS Microsoft Azure Foundations Benchmark recommendations. Additional policies will be added in upcoming releases. For more information, visit https://aka.ms/cisazure130-initiative."
  display_name                       = "CIS Microsoft Azure Foundations Benchmark v1.3.0"
  not_scopes                         = []
  policy_definition_id               = "/providers/Microsoft.Authorization/policySetDefinitions/612b5213-9160-4969-8578-1518bd2a000c"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  enforcement_mode                   = null
  location                           = "southeastasia"
  assign_identity                    = false
  management_group_set_definition    = null
  management_group_policy_definition = null
}

module "scb_policy_assignment_8" {
  source = "../"


  name                               = "NIST SP 800-53 Rev-5"
  description                        = "NIST SP 800-53 Rev. 5"
  display_name                       = "NIST SP 800-53 Rev. 5"
  not_scopes                         = []
  policy_definition_id               = "/providers/Microsoft.Authorization/policySetDefinitions/179d1daa-458f-4e47-8086-2a68d0d6c38f"
  scope                              = "/subscriptions/1901eaa9-e98f-49b6-ac39-b1cd55defe19"
  location                           = "southeastasia"
  assign_identity                    = true
  management_group_set_definition    = null
  management_group_policy_definition = null
}
