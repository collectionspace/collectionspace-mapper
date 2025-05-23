# Changelog
All notable changes to this project from 2021-03-09 onward will be documented in this file.

Changes made prior to 2021-03-09 may ever be added retrospectively, but consult [Github Releases for the project](https://github.com/collectionspace/collectionspace-mapper/releases/) in the indefinite meantime.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This project bumps the version number for any changes (including documentation updates and refactorings). Versions with only documentation or refactoring changes may not be released. Versions with bugfixes will be released. Changes made to unreleased versions will be indicated by version number under each release that includes those changes.

## [Planned]
- none

## [Unreleased] - i.e. pushed to main branch but not yet tagged as a release

## [6.1.1] - 2025-04-22
- BUGFIX: deriving config from RecordMapper does not break when new-style "dataConfigType" property is included
- DataHandler(s) can accept a URL for a mapper (or DataConfig, for new data-toolkit), and fetch/parse the JSON for use
- BUGFIX: [#185](https://github.com/collectionspace/collectionspace-mapper/issues/185) - Error adding a field subgroup with no data to a field group

## [6.1.0] - 2024-11-18
- Add `authority_terms_duplicate_mode` batch config setting that changes the way authority `shortIdentifier` values are generated, allowing near-duplicate terms to be created in a batch.
- BUGFIX: Authority terms consisting solely of non-Latin characters are no longer normalized to a blank string for `shortIdentifier` creation, and thus will not be flagged as duplicate terms.

## [6.0.4] - 2024-10-21
- Make fallback term search fully case-insensitive, rather than just capitalizing/downcasing first letter of term

## [6.0.3] - 2024-10-18
- BUGFIX: Rescue error when record status check finds more than one matching record, and add to Response errors for handling by ingest application

## [6.0.2] - 2024-09-13
- BUGFIX: DataHandler now handles batch config passed as a String

## [6.0.1] - 2024-08-30
- BUGFIX: Reponse did not get an identifier set if any terms were missing.

## [6.0.0] - 2024-08-24
- **Breaking**
  - Revert to activesupport v. 6.0.4.7 for compatibility with CSV Importer
  - `Response.terms` now returns an Array of `UsedTerm` objects instead of Hashes
- Add `UsedTerm.missing?` convenience method
- Fix bug where `DataHandler` could not handle a batch config passed as a String
- Fix bug where `HandlerFullRecord.process` failed if passed a Hash instead of a `Response`

## [5.0.6] - 2024-02-11
- Return date details responses early if there are errors, to avoid exceptions

## [5.0.5] - 2024-02-02
- For `date details` batch mode: add support for ingesting grouped fields at the same level as the structured date group. To find the group level of the structured date group, find the `date_field_group` value in the relevant CSV ingest template. If that field has a `REPEATING FIELD GROUP` value in the template, any other field values with the same `REPEATING FIELD GROUP` value can be ingested together.

## [5.0.4] - 2024-02-01
- Ensure `shortid` field is populated when mapping date details for authorities

## [5.0.3] - 2024-01-26
- Add `null_value_string_handling` batch configuration option, with ability to switch to creating empty string nodes, rather than deleting nodes.

## [5.0.2] - 2023-12-19
- BUGFIX for [#148](https://github.com/collectionspace/collectionspace-mapper/issues/148)

## [5.0.1] - 2023-04-25
- BUGFIX for [#165](https://github.com/collectionspace/collectionspace-mapper/issues/165)

## [5.0.0] - 2023-04-19
- **Possibly breaking**:
  - XML documents are no longer produced for Responses that are invalid (i.e. have one or more errors) at the end of the data transformation/prep phase.
  - Error definitions have all been moved to `CollectionSpace::Mapper::Error` module definition file, inherit from appropriate Ruby exception classes, and include `CollectionSpace::Mapper::Error` for scoping to the application. If any external applications rescue specific errors, failures may occur. The errors rescued will need to be updated.
  - The `CollectionSpace::Mapper.setup_data` method has been removed, as it was mainly introduced to support testing. All test-related code is now in the `./spec` directory. Creating a new Response object now requires not only the incoming data, but the relevant Handler class.

NOTE: The potential breaking changes have been accounted for in collectionspace-migration-tools, but not yet in collectionspace-csv-importer. **CSV Importer is stuck at 4.1.2 until it is updated to use Ruby 3.2, after which it should continue to use 4.1.3 until I can full test these changes with it**

- `DataHandler` now only takes incoming args, and determines what type of more specific Handler to return, based on the given args (including the new `batch_mode` setting in batch config). The main mapping functionality has now been moved to `HandlerFullRecord`.
- `DateDetails::Handler` is introduced to support ingest of structured date details fields into a specified structured date field group, via the same interface as `HandlerFullRecord`.

- (dev) Use VCR gem to speed up tests
- (dev) Major refactoring, including removal of unused code; pulling values used throughout the application into config set by initialization of Handler class; clean up code now that config can be referenced instead of passing around complicated arg signatures; FINALLY move xpath processing out of handler into its own object(s); move functionality and tests to more appropriate classes; major DRYing up of tests, including a custom XML document matcher.

## [4.1.3] - 2023-03-17
- Update for Ruby 3.2
- Add test coverage with simplecov
- Add linting to CI
- Clean up code/fix offenses

## [4.1.2] - 2022-12-02
- BUGFIX for [#153](https://github.com/collectionspace/collectionspace-mapper/issues/153)

## [4.1.1] - 2022-11-21
- BUGFIX for [#151](https://github.com/collectionspace/collectionspace-mapper/issues/151)

## [4.1.0] - 2022-11-17
- Adds ability to create new vocabulary terms. See [usage documentation](https://github.com/collectionspace/collectionspace-mapper/blob/main/doc/usage.adoc#add-vocabulary-terms).

## [4.0.7] - 2022-10-18
- BUGFIX for [#129](https://github.com/collectionspace/collectionspace-mapper/issues/129) and [#142](https://github.com/collectionspace/collectionspace-mapper/issues/142)

## [4.0.5, 4.0.6] - 2022-07-13
- `UnparseableUrnError` includes the unparseable URN it was given. 4.0.5 added a `:urn` attribute to to error class. 4.0.6 removed that and just puts the attempted URN in the error message attribute.

## [4.0.4] - 2022-07-12
- Stop adding duplicate "missing term" errors at point of retrieving client search results and later processing those results
- Ensure equivalence of interface (duck typing) for RefName and UnknownTerm classes
- Dev: clean up old comments/commented out code; run tests in deterministic random order (i.e. with reported seed); aggregate failures in tests globally via config

## [4.0.3] - 2022-06-23
- BUGFIX: Fixes error when calling `mappable` on a `ChronicParser` initialized with a date string Chronic cannot parse  - [PR 144](https://github.com/collectionspace/collectionspace-mapper/pull/144)
- Replace `facets` gem with `activesupport` - [PR 141](https://github.com/collectionspace/collectionspace-mapper/pull/141)
- <del>Handle all dependencies in Gemfile and remove .gemspec since this will never be released as a gem - [PR 141](https://github.com/collectionspace/collectionspace-mapper/pull/141)</del> -- Reverted in [PR 142](https://github.com/collectionspace/collectionspace-mapper/pull/142)


## [4.0.2] - 2022-06-07
Uses Zeitwerk eager loading (and custom inflection on version.rb to VERSION) to make `rails:zeitwerk` check pass when used with collectionspace-csv-importer.

## [4.0.1] - 2022-05-23

See [PR 138](https://github.com/collectionspace/collectionspace-mapper/pull/138) for more details on changes.

### Changed
- BUGFIX: Fixes error that could occur if an unknown term using different cases (i.e. U.S. Equestian Team vs. U.S. Equestrian team). TermHandler would check whether the second value was cached as unknown with case-swapping, and would return true. However, when actually fetching the cached value, case-swapping wasn't used, so a nil value would be returned and passed on, later causing a MethodMissing on nil error.

## [4.0.0] - 2022-05-13

See [PR 137](https://github.com/collectionspace/collectionspace-mapper/pull/137) for more details on changes.

### Breaking
- Initializing a `DataHander` now requires a `csid_cache` in addition to (refname) `cache` parameter.

### Added
- Rspec binstub
- New configuration option: `status_check_method` (defaults to `client`, but may be also set to `cache` for use with `collectionspace_migration_tools` (and code to support this configurable functionality)
- New configuration option: `search_if_not_cached` (defaults to `true`, but may be set to `false` for use with `collectionspace_migration_tools` (and code to support this configurable functionality)

### Changed
- Initializing a `DataHander` now requires a `csid_cache` in addition to (refname) `cache` parameter.
- Use `zeitwerk` for autoloading
- Refactoring to support configurable record status checkig via client API calls or cache
- When searching for relations (`client.find_relation`), sends the relation type
- All searching of CS instance moved to use `collectionspace-client` instead of `collectionspace-refcache`'s fallback searching. All search functionality has been removed from `collectionspace-refcache`
- All record status check logic moved out of `DataHandler`
- Test style consistency improved, and `integration` tag added to tests that compare full record mappings to fixture XML

### Deleted

## [3.0.0] - 2022-01-20

See [PR 136](https://github.com/collectionspace/collectionspace-mapper/pull/136) for more details on changes.

### Breaking
- `check_terms` batch configuration option is removed, as it is inherently unsafe
- Changes introduced will prevent `collectionspace-csv-importer` users from transferring records they previously were able to transfer

### Added
- Searching for "case-swapped" versions of terms not found in cache or target CS instance

### Changed
- Attaches an error, rather than a warning, to responses returned to `collectionspace-csv-importer` when record data includes authority or vocabulary terms that do not yet exist in target CS instance. This has the effect of preventing transfer of these records
- Both refname and csid of existing terms are cached on first lookup
- Terms or records found to be missing from target CS instance are cached as `unknownvalue` type entries
- Improved test coverage

### Deleted
- `check_terms` batch configuration option

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.5.2...v3.0.0

## [2.5.2] - 2022-01-14
### Added
- `strip_id_values` batch configuration option added. Setting this to `false` allows update of existing records with leading/trailing spaces on the record ID field values.

## [2.5.1] - 2021-10-13
### Changed
- accept and handle collectionspace-refcache passed in from collectionspace-csv-importer
- bug fixes for dealing with cached data
- refactoring

## [2.5.0] - 2021-09-23
### Added
- `multiple_recs_found` batch configuration option added to allow batch deletion of duplicate records. This defaults to `fail`, which means if there are two or more existing records sharing the same ID, the batch importer will not transfer anything for that ID. In rare cases, however, you may really need to delete duplicates, and now you can. The batch importer will transfer your update or delete to the first result found via a search for the record ID. See [the batch configuration options documentation](https://github.com/collectionspace/collectionspace-mapper/blob/main/doc/batch_configuration.adoc) for more information.

### Changed
- Do not warn about "%NULLVALUE%" as an unknown option list value

## [2.4.9] - 2021-09-03
### Changed
- Use Ruby 2.7.4 to stay in sync with collectionspace-csv-importer

## [2.4.8] - 2021-09-03
### Changed
- Bugfix for [collectionspace-csv-importer#110](https://github.com/collectionspace/collectionspace-csv-importer/issues/110)
- Re-set up running tests automatically on PR creation
- Use `collectionspace-client` v0.10.0 and the `find_relation` method added to it
- Use `collectionspace-refcache` v0.7.7
- Add tests for methods in `TermSearchable` module

## [2.4.7] - 2021-07-14
### Changed
- Use ruby v2.7.3
- Use `collectionspace-client` v0.9.0
- Use `collectionspace-refcache` v0.7.6

## [2.4.6] - 2021-07-13
### Changed
- `mediaFileURI` is included in the list of known columns for media procedure records.

## [2.4.5] - 2021-06-29
### Changed
- Bumps version of `collectionspace-client` to 0.8.0, to add support for all 6.1 record types and new 7.0 record types
- Bumps version of `collectionspace-refcache` to 0.7.4, which now also depends on `collectionspace-client` 0.8.0
- Sorts Dir files before requiring them to avoid load-order problems that are tricky to reproduce
- Explicitly requires dependent files to fix failures highlighted by introducing sort before requiring

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.4.4...v2.4.5

## [2.4.4] - 2021-06-21
### Added
- `Tools::RecordStatusService` raises `NoClientServiceError` instead of passing along a mysterious, hard to debug `KeyError`. This allows `collectionspace-csv-importer` to fail with an informative message.

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.4.3...v2.4.4

## [2.4.3] - 2021-06-21
### Changed
- Bumps version of `collectionspace-refcache` to 0.7.3, as this is the version now required by `collectionspace-csv-importer` for playing nice with Heroku

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.4.2...v2.4.3

## [2.4.2] - 2021-06-07
### Added
- Test coverage for %NULLVALUE% authority terms in repeating subgroups

### Changed
- Refactored core mapper tests

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.4.1...v2.4.2

## [2.4.1] - 2021-06-02
### Added
- Tests for vocabulary/authority-controlled fields containing %NULLVALUE% and THE BOMB

### Changed
- Term handler now passes through %NULLVALUE% as an empty string, and passes 💣 through as 💣. This means you no longer get spurious "not found" term warnings about these values, and they have the expected result when imported.

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.4.0...v2.4.1

## [2.4.0] - 2021-05-17
### Added
- Public `DataHandler.service_type` method so that `cspace-batch-import` does not reach into the guts of the class for that info

Details: https://github.com/collectionspace/collectionspace-mapper/compare/v2.3.2...v2.4.0

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
