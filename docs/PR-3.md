# Pull request 3: add SonarQube Cloud quality reporting

## Motivation

Bring this maintained transport fork under the same exact-commit SonarQube
Cloud policy and README reporting used by the rest of the Container family.

## Implementation

- Add a project-scoped scanner configuration and previous-version policy validation.
- Export LLVM's native line-accurate LCOV data and deterministically convert it
  to SonarQube generic coverage with unit tests.
- Add local `make coverage`, `make sonar-scan`, and `make sonar` entry points.
- Add an exact-revision GitHub workflow for pull requests, `main`, and manual recovery.
- Retain coverage evidence and reject unresolved new-code issues or security hotspots.
- Add the complete standard metric badge set to the README.

## Validation

- `make coverage`
- `python3 -m unittest discover Tools/coverage`

The full local package suite passes and the native report records 89.21%
first-party line coverage (9,944 of 11,147 lines). The small C zlib shim remains
excluded because it is vendored compatibility code rather than maintained
Swift source.

- `actionlint .github/workflows/sonar.yml`
- `markdownlint README.md docs/*.md`
- `git diff --check`
- Authoritative pull-request and merged-`main` SonarQube Cloud quality gates

## Compatibility

No package product, public API, dependency, runtime, integration, or release
behavior changes.

## Rollback

Revert the infrastructure commit and remove the corresponding SonarQube Cloud
project if the integration must be withdrawn. No source or data migration is
required.

## Links

- Tracks the repository-local issue document: [ISSUE-quality-add-sonarcloud.md](ISSUE-quality-add-sonarcloud.md)
- Pull request: [#3](https://github.com/stephenlclarke/grpc-swift-nio-transport/pull/3)
