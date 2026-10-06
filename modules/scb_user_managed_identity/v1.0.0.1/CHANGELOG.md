# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - add optional federated_identity_credentials and role_assignments

### Added

- Optional `federated_identity_credentials` variable to create GitHub OIDC (and other) federated identity credentials on the User Assigned Managed Identity.
- New outputs `federated_identity_credential_ids` and `federated_identity_credential_names` exposing created credential IDs and names as maps.
- Optional `role_assignments` variable to create RBAC assignments for the managed identity principal.
- New output `role_assignment_ids` exposing created role assignment IDs as a map.

### Changed

- Replaced deprecated `resource_group_name` and `parent_id` arguments in `azurerm_federated_identity_credential` with the current `user_assigned_identity_id` argument (azurerm >= 4.x).
- Guarded federated identity credential creation against `null` input so `federated_identity_credentials = null` safely creates no credentials.
- Made `role_assignments` validations null-safe to prevent plan-time function argument errors when optional `condition` or `principal_type` are omitted.

## [1.0.0.0] - Initial Release

### Added

- Create Azure User Assigned Managed Identity Terraform Module.
- Federated identity credentials support.
- Management locks and role assignments.
- Telemetry integration.
