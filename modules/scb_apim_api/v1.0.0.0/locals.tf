locals {
  # Flatten API operations into a single map for resource creation
  api_operations = merge([
    for api_key, api in var.apis : {
      for operation_key, operation in api.operations : "${api_key}-${operation_key}" => merge(operation, {
        api_key = api_key
      })
    }
  ]...)

  # Flatten operation-level policies into a single map
  # operation_policies = merge([
  #   for api_key, api in var.apis : {
  #     for operation_key, operation in api.operations : "${api_key}-${operation_key}" => {
  #       api_key     = api_key
  #       xml_content = operation.policy != null ? operation.policy.xml_content : null
  #       xml_link    = operation.policy != null ? operation.policy.xml_link : null
  #     } if operation.policy != null
  #   }
  # ]...)
  operation_policies = merge([
    for api_key, api in var.apis : {
      for operation_key, operation in api.operations : "${api_key}-${operation_key}" => {
        api_key      = api_key
        operation_id = operation_key
        policy       = operation.policy
      } if operation.policy != null
    }
  ]...)

}
