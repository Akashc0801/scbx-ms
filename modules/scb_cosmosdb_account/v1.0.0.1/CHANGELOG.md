# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-10-07

### Added

- Input `diagnostic_settings` and resource `azurerm_monitor_diagnostic_setting.this`.
- Input `lock` and resource `azurerm_management_lock.this`. The lock depends on every other resource in the module so it is created last and removed first.
- Outputs `diagnostic_setting_ids` and `lock_id`.

### Changed

- Naming module call now passes only the inputs `scb_naming_module/v1.0.0.1` accepts; business, finance and optional tags are passed through `additional_tags`. v1.0.0.0 failed `terraform validate`.
- `product_name` and `product_version` default to `scb_cosmosdb_account` and `1.0.0.1`.

## [1.0.0] - 2026-04-14 Initial Release

### Added

- Create Cosmos DB Account Terraform Module.
