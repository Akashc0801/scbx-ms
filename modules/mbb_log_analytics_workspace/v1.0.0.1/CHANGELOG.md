# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0.1] - 2026-04-15

### Added

- Added inputs: `experiment_phase`, `integration_id`, `last_vm_accessed`, `maintenance_window`, `os`, `patch_policy`, `retention`, `sandbox_type`, and `service`.

### Changed

- Updated module interface toward Maybank governance and lifecycle metadata alignment.
- No resource, data source, output, or provider-constraint changes between `v1.0.0.0` and `v1.0.0.1`.

### Removed

- Removed inputs: `app_support`, `cost_allocation_unit`, `country`, and `product_version`.

## [1.0.0.0] - 2026-04-15 Initial Release

### Added

- Create Log Analytics Workspace Terraform Module.
