## [Unreleased]

- Add `OpenProject/NoParamsInWorkPackageWhereId` cop to catch
  `WorkPackage.where(id: params[...])` patterns that silently drop semantic
  identifiers (e.g. `"PROJ-42"`) when PostgreSQL casts the string to integer 0.

## [0.4.0] - 2026-03-27

- Add NoNotImplementedError cop

## [0.3.0] - 2025-07-11

- Remove redundant NoDoEndBlockWithRSpecCapybaraMatcherInExpect cop

## [0.2.0] - 2024-10-18

- Add `OpenProject/NoSleepInFeatureSpecs` cop to check that `sleep` calls in
  feature specs are not greater than 1 second.

## [0.1.0] - 2024-07-05

- Initial release
