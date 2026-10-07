# Changelog
<!-- markdownlint-disable MD024 -->

[[_TOC_]]

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- ## [Unreleased]

### Added

### Changed

### Removed -->

## [Unreleased]

### Added

- Added the opt-in `workload` naming format and independent `location_region_code`; the default `legacy` format remains available.
- Made `region_code` nullable and omit absent region components from generated names.

## [1.0.0] - 2023-06-08 - Initial Handover

### Added

- Added Naming Module.