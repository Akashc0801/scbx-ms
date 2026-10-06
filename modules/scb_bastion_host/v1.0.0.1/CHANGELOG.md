# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-04-14

### Added

- Added SCB governance and lifecycle metadata inputs for bastion host deployments.
- Added new outputs: `location`, `public_ip_address`, and `tags`.

### Changed

- Updated module interface to support resource-group-id based targeting.
- Updated provider constraint style in `terraform.tf`.
- No resource changes between `v1.0.0.0` and `v1.0.0.1`.

### Removed

- Removed inputs: `app_support`, `cost_alert_threshold`, `cost_allocation_unit`, `country`, `product_name`, `product_version`, and `resource_group_name`.
- Removed data source: `data.azurerm_subscription.current`.

## [1.0.0.0] - 2026-04-14 Initial Release

### Added

- Create Bastion Host Terraform Module.
