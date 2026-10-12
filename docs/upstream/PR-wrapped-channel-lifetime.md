# fix: dispose wrapped channels during early shutdown

## Motivation

An eagerly configured wrapped channel can outlive or be released before its connection runner, leaving its async writer unfinished. Queued streams also need a terminal result when shutdown or configuration failure prevents readiness.

## Changes

Idle shutdown takes scoped ownership of the configured async channel and closes it. Shutdown during configuration uses `executeThenClose`, which finishes the writer as well as the socket. The state machine returns queued continuations for failure on shutdown and failed configuration. The additive `close()` API begins graceful shutdown and awaits underlying channel closure; a caller separately awaits any running connection task. Repeated shutdown does not start a second async-channel consumer.

## Validation

Three focused regressions pass: closing an active configured channel before connect, shutdown during configuration and terminal state, and queued requests failing on idle/configuring shutdown or failed configuration. The configuration race test exercises state transitions; it does not simulate every real channel interleaving. All 542 applicable core and HTTP/2 transport cases pass; one existing host-vsock applicability skip remains recorded. Focused Swift formatting, license headers and Markdown validation pass. Raw logs and exact source hashes are retained with the immutable checkpoint.

## Compatibility and remaining risk

Public existing initializers, factory and protocol signatures remain unchanged. Active connections retain the normal graceful GOAWAY path. The SDK socketpair regressions additionally verify immediate close with an open or already closed peer after consuming the signed dependency revision. Full matched-stack runtime qualification remains a later gate; no performance improvement is claimed by this lifetime correction.

Related: [issue handoff](ISSUE-wrapped-channel-lifetime.md).
