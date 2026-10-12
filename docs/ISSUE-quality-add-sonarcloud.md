# Issue: add SonarQube Cloud quality reporting

## Problem

This maintained Container-family Swift repository has no SonarQube Cloud
analysis, coverage evidence, or README quality badges. That leaves reliability,
security, maintainability, duplication, and coverage changes without the
family-wide quality authority.

## Required outcome

- Create a public `stephenlclarke_grpc-swift-nio-transport` project.
- Apply the project-level `Previous version` new-code definition.
- Analyze exact Git commits and reject unresolved new-code issues and security hotspots.
- Generate retained first-party Swift coverage reports.
- Add the standard Container-family SonarQube badge set to `README.md`.

## Compatibility and risk

The change is development infrastructure only. It does not modify package
products, public API, runtime behavior, dependency pins, or upstream source
semantics. The C zlib shim has no executable Swift coverage and is excluded
from that metric, while it remains in static analysis.

## Current-revision coverage integrity

The local exact-head run at `8b9f95e6` passes 542 native cases with one pre-existing Vsock applicability skip (466 XCTest cases including the skip and 77 Swift Testing cases). Its coverage is invalid: six LCOV counters wrap to `18446744073709551615` or `18446744073709551613` in concurrent event-loop handlers. The old converter classifies these impossible counts as covered. Raw LCOV, XML, logs and the original undercounting controller receipt are retained with a separate disposition; the reported 89.27% is not accepted coverage. The correction requires atomic Swift/Clang counters, rejects impossible counters/nonpositive source lines and removes stale XML before testing. Fresh instrumented qualification is required before Sonar analysis.
