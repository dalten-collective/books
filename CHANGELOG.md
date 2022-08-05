# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [UNRELEASED]

### Added

- Validation for tags everywhere

### Changed

- Add loading state to tag manipulation on existing records
- All API calls expect tag arrays; include helper function for handling
- Disallow underscores in tags

### Fixed

- Validation on new Wallet, new Friend

## [1.1.0] - 2022-08-04

### Changed

- Separate add/edit annotation UI to address "reactivity" of updates

### Fixed

- Validations for annotation (Basis and Tags)
- Don't show nonexistent annotations

## [1.0.0] - 2022-07-09

### Added

- Add counterparty column and filter
- Add fees column
- Add sort to In/Out/Fee columns
- Add loading state on annotations save button
- Add tags to annotations; filtering for same
- Add loading state to Ledger table and Home mini-table

### Fixed

- Annotations changes not entering vuex on set-annotations
- Friends tags

## [0.1.0]

### Added

- Base version
