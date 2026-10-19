# fix(ci): bind transport quality checks to current source

## Problem and behavior

Refresh the existing quality branch with current fork fixes and upstream `9765a256477383b9d441f20952118b75104304e8`. Local scans require clean tracked source, a matching coverage revision and an unchanged report. A named local branch is explicit; GitHub Actions keeps automatic CI context.

## Validation

The actual Make scan target is exercised with a local scanner double for valid branch/version admission, CI context, stale and missing provenance, modified reports, dirty source, detached checkouts and version override attempts. Run the original transport suite against the updated dependency graph and retain its resolved revisions. No live scanner or historical benchmark is invoked by the regression tests.

## Compatibility and risks

Existing coverage must be regenerated once to create provenance sidecars. Existing package consumers keep their resolved revisions. Coverage remains a measured quality result, not inferred from passing tests. Related: [issue](ISSUE-quality-refresh-20261019.md) and [existing PR 3](https://github.com/stephenlclarke/grpc-swift-nio-transport/pull/3).
