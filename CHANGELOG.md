# Changelog
All notable changes to this project from 2021-03-09 onward will be documented in this file.

Changes made prior to 2021-03-09 may ever be added retrospectively, but consult [Github Releases for the project](https://github.com/collectionspace/collectionspace-mapper/releases/) in the indefinite meantime.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This project bumps the version number for any changes (including documentation updates and refactorings). Versions with only documentation or refactoring changes may not be released. Versions with bugfixes will be released. Changes made to unreleased versions will be indicated by version number under each release that includes those changes.

## [Unreleased]

## [2.4.4] - 2021-06-21
### Added
- `Tools::RecordStatusService` raises `NoClientServiceError` instead of passing along a mysterious, hard to debug `KeyError`. This allows `collectionspace-csv-importer` to fail with an informative message.

## [2.4.3] - 2021-06-21
### Changed
- Bumps version of `collectionspace-refcache` to 0.7.3, as this is the version now required by `collectionspace-csv-importer` for playing nice with Heroku

## [2.4.2] - 2021-06-07
### Added
- Test coverage for %NULLVALUE% authority terms in repeating subgroups

### Changed
- Refactored core mapper tests

## [2.4.1] - 2021-06-02
### Added
- Tests for vocabulary/authority-controlled fields containing %NULLVALUE% and THE BOMB

### Changed
- Term handler now passes through %NULLVALUE% as an empty string, and passes 💣 through as 💣. This means you no longer get spurious "not found" term warnings about these values, and they have the expected result when imported.

## [2.4.0] - 2021-05-17
### Added
- Public `DataHandler.service_type` method so that `cspace-batch-import` does not reach into the guts of the class for that info

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.3.2...v2.3.3

## [2.3.1], [2.3.2] - 2021-05-17
### Deleted 
- Development dependency on ruby-prof that should not have been committed

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.3.0...v2.3.2

## [2.3.0] - 2021-05-17
### Added
- Implements "the bomb" for deleting existing field values. See [the PR](https://github.com/collectionspace/collectionspace-mapper/pull/108) for details.
- This release also includes unreleased refactored code from 2.2.6

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.2.5...v2.3.0

## [2.2.6 (Unreleased)] - 2021-04-30
### Changed
- Refactoring

## [2.2.5] - 2021-04-22
### Added
- CHANGELOG.md

### Changed
- BUGFIX: Fixes an issue where, when many records are mapped using the same `DataHandler`, some XML records were missing expected elements.

### Deleted
- Tests for UCB-specific mapping. These tests had served their purpose, were no longer needed, and were not worth fixing when they started to fail because the dev instance on UCB's end changed or went away.

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.2.3...v2.2.5

## [2.2.4 (Unreleased)] - 2021-03-25

- Updated values in fixtures causing test failures due to records being deleted from CollectionSpace dev instance

## [2.2.3] - 2021-03-09
### Changed
- BUGFIX: Spurious warnings about subgroup overflows are no longer emitted

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.2.2...v2.2.3
