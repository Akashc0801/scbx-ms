# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.2] - 2026-10-07

### Added

- `ai_foundry_accounts[*].diagnostic_settings` and resource `azurerm_monitor_diagnostic_setting.ai_foundry_account`. v1.0.0.1 only supported diagnostic settings on projects.
- `ai_foundry_accounts[*].lock` and resource `azurerm_management_lock.ai_foundry_account`. The lock depends on every other resource in the module so it is created last and removed first.
- Outputs `ai_foundry_account_diagnostic_setting_ids` and `ai_foundry_account_lock_ids`.
- `tests/interfaces.tftest.hcl` (mocked providers, `terraform test`).

### Changed

- `ProductName` tag corrected from `scb_ms_foundry_dev` to `scb_ms_ai_foundry`; `ProductVersion` tag and naming `product_version` set to `1.0.0.2` (v1.0.0.1 reported `1.0.0.0`).

### Fixed

- Project and account connections failed to plan when any connection carried credentials (for example an App Insights connection string): the map became sensitive and could not be used in `for_each`. The child modules now iterate over the connection keys.
- Role assignments failed with `expected "description" to not be an empty string`: `role_assignments[*].description` and `project_role_assignments[*].description` now default to `null` instead of `""`.

### Notes

- A `CanNotDelete` lock on the account also blocks deleting its projects, model deployments and connections. Removing any of these later needs the lock removed first (set `lock = null`, apply, then make the change).
