# --- Naming Convention Variables ---

variable "type" {
  description = "The type segment of the group name."
  type        = string

  validation {
    condition     = contains(["SG", "RAG"], var.type)
    error_message = "Type must be either \"SG\" or \"RAG\"."
  }
}


variable "tier" {
  description = "The tier segment of the group name."
  type        = string

  validation {
    condition     = contains(["T0", "T1", "T2", "T3"], var.tier)
    error_message = "Tier must be one of \"T0\", \"T1\", \"T2\", or \"T3\"."
  }
}

variable "scope" {
  description = "The scope segment of the group name."
  type        = string
  default     = ""

  validation {
    condition     = var.scope == "" || contains(["Root", "SCB", "CEN", "REG", "BU", "SBX", "APP", "APL", "DATA"], var.scope)
    error_message = "Scope must be empty or one of \"Root\", \"SCB\", \"CEN\", \"REG\", \"BU\", \"SBX\", \"APP\", \"APL\", or \"DATA\"."
  }
}

variable "bu_code" {
  description = "(Optional) The business unit code segment of the group name. Required if scope is BU or APP."
  type        = string
  default     = ""

  validation {
    condition     = !contains(["BU", "APP"], var.scope) || var.bu_code != ""
    error_message = "bu_code must be provided if scope is \"BU\" or \"APP\"."
  }
}

variable "app_code" {
  description = "(Optional)The application code segment of the group name. Required if scope is APP or APL. "
  type        = string
  default     = ""
}

variable "rolecode" {
  description = "Short code for the Entra role or the functional group if multiple roles"
  type        = string

}

variable "function" {
  description = "The function segment of the group name."
  type        = string
  default     = ""

  validation {
    condition     = var.function == "" || contains(["Members", "Approvers", "Owners"], var.function)
    error_message = "Group Function must be empty or one of \"Members\", \"Approvers\", or \"Owners\". "
  }
}

variable "env" {
  description = "The environment segment of the group name."
  type        = string
  default     = ""

  validation {
    condition     = var.env == "" || contains(["Prod", "NonProd", "Dev", "Test", "UAT", "SBX"], var.env)
    error_message = "Environment must be either empty or one of \"Prod\", \"NonProd\", \"Dev\", \"Test\", \"UAT\", or \"SBX\". "
  }
}

variable "region" {
  description = "The region segment of the group name."
  type        = string
  default     = ""

  validation {
    condition     = var.region == "" || contains(["MY", "SG", "ID", "AU"], var.region)
    error_message = "Region must be either empty or one of \"MY\", \"SG\", \"ID\", or \"AU\"."
  }
}

# --- Resource Variables ---

variable "administrative_unit_ids" {
  description = "The object IDs of administrative units in which the group is a member."
  type        = set(string)
  default     = []
}

variable "assignable_to_role" {
  description = "Indicates whether this group can be assigned to an Azure Active Directory role. Can only be set to true for security-enabled groups."
  type        = bool
  default     = false
}

variable "description" {
  description = "The description for the group."
  type        = string
  default     = ""
}

variable "members" {
  description = "A set of members who should be present in this group. Supported object types are Users, Groups or Service Principals."
  type        = set(string)
  default     = []
}

variable "security_enabled" {
  description = "Whether the group is a security group for controlling access to in-app resources. At least one of security_enabled or mail_enabled must be specified."
  type        = bool
  default     = true
}

variable "owners" {
  description = "A set of object IDs of principals that will be granted ownership of the group."
  type        = set(string)
  default     = []
}

variable "prevent_duplicate_names" {
  description = "If true, will return an error if an existing group is found with the same name."
  type        = bool
  default     = false
}

variable "visibility" {
  description = "The group join policy and group content visibility. Possible values are Private, Public, or Hiddenmembership."
  type        = string
  default     = null
}
