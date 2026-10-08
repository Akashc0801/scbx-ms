# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## [1.0.0] - 2026-04-14 Initial Release

### Added

- Create App Insights Terraform Module.

### Updated 2026-10-08 (before first deployment, no version change)

#### Added

- Input `diagnostic_settings` and resource `azurerm_monitor_diagnostic_setting.this`, to export telemetry to Event Hubs, Storage or another Log Analytics workspace.
- Output `diagnostic_setting_ids`.
- `tests/interfaces.tftest.hcl` (mocked providers, `terraform test`).

#### Changed

- The lock now depends on the diagnostic settings, private link scope and linked storage resources, so it is created last and removed first.

#### Fixed

- Outputs `instrumentation_key` and `resource` are now marked `sensitive`. Without this the module failed when used as a root module (for example under `terraform test`). Values were already sensitive in the provider, so callers see no change.
- `ProductVersion` tag and naming `product_version` corrected to `1.0.0.0` (were `1.0.0.1`).
- Optional `naming_format` and `location_region_code` pass-through; `region_code` may be null.
