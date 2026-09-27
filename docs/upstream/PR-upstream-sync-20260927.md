# chore: synchronize container dependency with upstream

## Changes

Merge upstream once-per-connection transport context and header-limit test updates.

Upstream: [grpc/grpc-swift-nio-transport@ff4420d7c33c](https://github.com/grpc/grpc-swift-nio-transport/commit/ff4420d7c33cc998a590b0761630d67f76bc291e).

## Validation

Bazel GRPCNIOTransportCoreTests passed (5.5 seconds) and GRPCNIOTransportHTTP2Tests passed (2.4 seconds). Source-only staged trees were tested through the reduced container Bazel workspace. Logs, test reports, and pre-merge bundles are retained under `ContainerFamily/retained/container-only/upstream-sync/20260927T123656Z`.

## Compatibility and risks

No history rewrite or dependency migration. This focused check does not claim a new complete container runtime benchmark.

## Related work

See [the matching issue](ISSUE-upstream-sync-20260927.md).
