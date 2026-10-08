# Changelog

[[_TOC_]]

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]
### Added
### Changed
### Removed -->

## Updated 2026-10-08 (before first deployment, no version change)

### Added

- Input `entra_authentication_as_arm_enabled` and resource `azapi_update_resource.entra_authentication_as_arm` to pin the registry policy `azureADAuthenticationAsArmPolicy` (needed by Foundry hosted agents). Default `null` leaves it unmanaged.
- Optional `naming_format` and `location_region_code` pass-through; `region_code` may be null.


## [1.0.0] - 2026-06-12 Initial Release

### Added

- Create Azure Container Registry Terraform Module.
